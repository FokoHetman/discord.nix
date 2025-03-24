{ lib, config, ... }:

let
  cfg = config.discord;

  /* PERMISSIONS */
  permsBool = 
    description: lib.mkOption {type = lib.types.nullOr lib.types.bool;default=null; inherit description;};
  permission_type = lib.types.submodule {
    options = {
      sendMessages = permsBool "Should this role be able to send message on this channel?";
      viewChannel = permsBool "Should this role be able to view this channel?";
    };
  };

  role_permission_type = lib.types.submodule {
    options = {
      sendMessages = permsBool "Should this role be able to send messages?";
      viewChannels = permsBool "Should this role be able to see channels?";
      manageChannels = permsBool "Should this role be able to manage channels?";
    };
  };


  category_permissions = lib.mkOption {
    description = "Global permissions of this category.";             
    type = permission_type;
    default = {};
  };
  channel_permissions = lib.mkOption {
    description = "Permissions of this channel.";             
    type = permission_type;
    default = {};
  };

  role_permissions = lib.mkOption {
    description = "Global permissions of this role.";
    type = role_permission_type;
    default = {};
  };

  /* CHANNELS */
  channels = lib.mkOption {
    description = "Set of channels in the category.";
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        roles = lib.mkOption {
          description = "Role permissions across this channel.";
          type = lib.types.attrsOf (lib.types.submodule {
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
  categories = lib.mkOption {
    description = "Set of categories in the server.";
            
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        inherit channels;
        roles = lib.mkOption {
          description = "Role permissions across this category.";
          type = lib.types.attrsOf (lib.types.submodule {
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
  roles = lib.mkOption {
    description = "Set of server roles defined via this module.";
    type = lib.types.attrsOf (lib.types.submodule {
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
      enable = lib.mkOption {
        description = "Whether to enable this module.";
        type = lib.types.bool;
        default = false;
      };
      servers = lib.mkOption {
        description = "Set of servers controlled via this module.";
        
        type = lib.types.attrsOf (lib.types.submodule {
          options = {inherit categories roles;};
        });
        default = {};
      };
    };
  };

  config = {
  };
}
