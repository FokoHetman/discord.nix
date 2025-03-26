{ config, options, lib, pkgs, ... }:
with lib;  
let
  cfg = config.discord;
  /* PERMISSIONS */
  permsBool = 
    description: mkOption {type = types.nullOr types.bool;default=null; inherit description;};
  permission_type = types.submodule {
    options = {
      sendMessages = permsBool "Should this role be able to send message on this channel?";
      viewChannel = permsBool "Should this role be able to view this channel?";
    };
  };

  role_permission_type = types.submodule {
    options = {
      sendMessages = permsBool "Should this role be able to send messages?";
      viewChannels = permsBool "Should this role be able to see channels?";
      manageChannels = permsBool "Should this role be able to manage channels?";
    };
  };


  category_permissions = mkOption {
    description = "Global permissions of this category.";             
    type = permission_type;
    default = {};
  };
  channel_permissions = mkOption {
    description = "Permissions of this channel.";             
    type = permission_type;
    default = {};
  };

  role_permissions = mkOption {
    description = "Global permissions of this role.";
    type = role_permission_type;
    default = {};
  };

  /* CHANNELS */
  channels = mkOption {
    description = "Set of channels in the category.";
    type = types.attrsOf (types.submodule {
      options = {
        roles = mkOption {
          description = "Role permissions across this channel.";
          type = types.attrsOf (types.submodule {
            options = {
              permissions = channel_permissions;
            };
          });
          default = {};
        };
        type = mkOption {
          description = "Type of the channel.";
          type = types.enum ["text" "voice"];
          default = "text";
        };
      };
    });
  };
  /* CATEGORIES */
  categories = mkOption {
    description = "Set of categories in the server.";
            
    type = types.attrsOf (types.submodule {
      options = {
        inherit channels;
        roles = mkOption {
          description = "Role permissions across this category.";
          type = types.attrsOf (types.submodule {
            options = {
              permissions = category_permissions;
            };
          });
          default = {};
        };
      };
    });
    default = {};
  };
  /* ROLES */
  roles = mkOption {
    description = "Set of server roles defined via this module.";
    type = types.attrsOf (types.submodule {
      options = {
        permissions = role_permissions;
      };
    });
    default = {};
  };
  sync_data = pkgs.writers.writePython3Bin "discord_sync" {
    libraries = with pkgs.python3Packages; [ requests json5 ]; } ''
import json, requests
f = open("${cfg.token_path}")
token = f.read()
f.close()


print(requests.get('https://discord.com/api/users/@me/guilds', headers = {
    "Authorization": token,
    "Content-Type": "application/json"
}))


'';

  
in
{
  options = {
    discord = {
      enable = mkOption {
        description = "Whether to enable this module.";
        type = types.bool;
        default = false;
      };
      token_path = mkOption {
        description = "Path to your discord token.";
        type = types.str;
        default = "";
      };
      servers = mkOption {
        description = "Set of servers controlled via this module.";
        
        type = types.attrsOf (types.submodule {
          options = {inherit categories roles;};
        });
        default = {};
      };
    };
  };
  config = mkIf cfg.enable {
    # YOU LAZY DUMBFOK REWRITE IT AS STRING CONCATS!!!! (probably very hard but shut up)
    system.activationScripts."discord" = ''
      #echo Hi, user with TOKEN: $(cat ${cfg.token_path}) # do not echo it in prod, dumbfok
    
      mkdir /tmp/discord_sync
      # curl to a json guilds & channels of needed guilds (yes, you can use a python script absolute dumbfok)


      echo '${builtins.toJSON cfg}' > /tmp/discord_sync/config.json
      
      ${sync_data}
      #rm -r /tmp/discord_sync
    '';
  };
}
