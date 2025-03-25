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
in
{
  options = {
    discord = {
      enable = mkOption {
        description = "Whether to enable this module.";
        type = types.bool;
        default = false;
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
    system.activationScripts."discord" = ''
      echo \"hi!\"
    '';
  };
}
