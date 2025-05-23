{ config, options, lib, pkgs, ... }:
with lib;  
let
  cfg = config.discord;
  /* PERMISSIONS */
  permsBool = 
    description: mkOption {type = types.nullOr types.bool;default=null; inherit description;};
  permission_type = types.submodule {
    options = /*list: value: builtins.listToAttrs (map (name: { name = name; value = value; }) list) ["createInstantInvite" "kickMembers" "banMembers" "administrator" "manageChannels" "manageGuild" "addReactions" "viewAuditLog" "prioritySpeaker" "stream" "viewChannel" "sendMessages" "sendTtsMessages" "manageMessages" "embedLinks" "attachFiles" "readMessageHistory" "mentionEveryone" "useExternalEmojis" "viewGuildInsights" "connect" "speak" "muteMembers" "deafenMembers" "moveMembers" "useVad" "changeNickname" "manageNicknames" "manageRoles" "manageWebhooks" "manageEmojisAndStickers" "useApplicationCommands" "requestToSpeak" "manageEvents" "manageThreads" "createPublicThreads" "createPrivateThreads" "useExternalStickers" "sendMessagesInThreads" "useEmbeddedActivities" "moderateMembers" "viewCreatorMonetizationAnalytics" "useSoundboard" "createGuildExpressions" "createEvents" "useExternalSounds" "sendVoiceMessages" "sendPolls" "useExternalApps"] (permsBool "A permission.");*/


    {

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
  # DO THE SAME FOR CATEGORIES
  
  # I AM TO HIGH TO DO THAT SORRY

  channels = mkOption {
    description = "Set of channels in the category.";
    default = {};
    type = types.attrsOf (types.submodule {
      options = {
        permissions = mkOption {
          type = types.submodule {
            options = {
              roles = mkOption {
                description = "Role permissions across this channel.";
                type = types.attrsOf (permission_type);
                default = {};
              };
              users = mkOption {
                description = "User permissions across this channel.";
                type = types.attrsOf (permission_type);
                default = {};
              };
              sync = mkOption {
                description = "Sync permissions to category.";
                type = types.bool;
                default = false;
              };
            };
          };
          default = {};
        };
        type = mkOption {
          description = "Type of the channel.";
          type = types.enum ["text" "voice" "forum" "announcements"];
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
        permissions = mkOption {
          type = types.submodule {
            options = {
              roles = mkOption {
                description = "Role permissions across this category.";
                type = types.attrsOf (permission_type);
                default = {};
              };
              users = mkOption {
                description = "Role permissions across this category.";
                type = types.attrsOf (permission_type);
                default = {};
              };
            };
          };
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
        hoist = mkOption {
          description = "Whether to display the role owners separately in members tab.";
          type = types.bool;
          default = false;
        };
        mentionable = mkOption {
          description = "Allow others to mention this role.";
          type = types.bool;
          default = false;
        };
        color = mkOption {
          description = "Role RGB color.";
          type = types.integer;
          default = 0;
        };
      };
    });
    default = {};
  };
  sync_data = pkgs.writers.writePython3Bin "discord_sync" {
    libraries = with pkgs.python3Packages; [ requests json5 ];
    flakeIgnore = ["E111" "E114" "E121" "E221" "E251" "E127" "E128" "E201" "E202" "W291" "W293" "W391" "E265" "E302" "E303" "E305" "E501" "E231" "E261" "E225"];
  } /*python3*/ ''
import requests
import json


api = "https://discord.com/api"

print("discord.nix: Starting...")

f = open("${cfg.token_path}")
token = f.read()
f.close()

f = open("/tmp/discord_sync/config.json")
config = json.load(f)
f.close()

headers = {"Authorization": token, "Content-Type": "application/json"}

guilds = requests.get(f'{api}/users/@me/guilds', headers=headers).json()


def camel_case(text):
    s = text.lower().replace("-", " ").replace("_", " ")
    s = s.split()
    if len(text) == 0:
        return text
    return s[0] + ''\''.join(i.capitalize() for i in s[1:])

perms = list(map(camel_case, [
  "CREATE_INSTANT_INVITE",
  "KICK_MEMBERS",
  "BAN_MEMBERS",
  "ADMINISTRATOR",
  "MANAGE_CHANNELS",
  "MANAGE_GUILD",
  "ADD_REACTIONS",
  "VIEW_AUDIT_LOG",
  "PRIORITY_SPEAKER",
  "STREAM",
  "VIEW_CHANNEL",
  "SEND_MESSAGES",
  "SEND_TTS_MESSAGES",
  "MANAGE_MESSAGES",
  "EMBED_LINKS",
  "ATTACH_FILES",
  "READ_MESSAGE_HISTORY",
  "MENTION_EVERYONE",
  "USE_EXTERNAL_EMOJIS",
  "VIEW_GUILD_INSIGHTS",
  "CONNECT",
  "SPEAK",
  "MUTE_MEMBERS",
  "DEAFEN_MEMBERS",
  "MOVE_MEMBERS",
  "USE_VAD",
  "CHANGE_NICKNAME",
  "MANAGE_NICKNAMES",
  "MANAGE_ROLES",
  "MANAGE_WEBHOOKS",
  "MANAGE_EMOJIS_AND_STICKERS",
  "USE_APPLICATION_COMMANDS",
  "REQUEST_TO_SPEAK",
  "MANAGE_EVENTS",
  "MANAGE_THREADS",
  "CREATE_PUBLIC_THREADS",
  "CREATE_PRIVATE_THREADS",
  "USE_EXTERNAL_STICKERS",
  "SEND_MESSAGES_IN_THREADS",
  "USE_EMBEDDED_ACTIVITIES", 
  "MODERATE_MEMBERS",
  "VIEW_CREATOR_MONETIZATION_ANALYTICS",
  "USE_SOUNDBOARD",
  "CREATE_GUILD_EXPRESSIONS",
  "CREATE_EVENTS",
  "USE_EXTERNAL_SOUNDS",
  "SEND_VOICE_MESSAGES",
  "SEND_POLLS",
  "USE_EXTERNAL_APPS"
]))

def build_permissions(current_overrides, discord_roles, roles, users, guild_id):
  # iterate users too
  result = []
  for i in roles:
    role_id = -1
    if i.isnumeric():
      role_id = i
    else:
      for j in discord_roles:
        if j["name"]==i:
          role_id = j["id"]
      if role_id == -1 and i=="everyone":
        role_id = guild_id
    if int(role_id)<0:
      raise Exception("non existent role")

    allow = 0
    deny = 0
    for permission in roles[i]:
      if roles[i][permission]:
        allow |= (1 << perms.index(permission))
      elif roles[i][permission] is False:
        deny  |= (1 << perms.index(permission))

    res = {}
    res["id"] = role_id
    res["type"] = 'role'
    res["allow"] = allow
    res["deny"] = deny
    result.append(res)


  return result

for i in guilds:
  if i["name"] in config["servers"]: # add id checking too later, for name redefining
    chctg = requests.get(f"{api}/guilds/{i['id']}/channels", headers=headers).json()
    roles = requests.get(f"{api}/guilds/{i['id']}/roles", headers=headers).json()
    print(chctg)
    categories = []
    channels = []
    category_pos = -1
    for x in chctg:
      match x["type"]:
        case 4: # Category
          categories.append(x)
        case 2: # Channel
          channels.append(x)
        case 0: #
          channels.append(x)
        case _:
          pass


    for category in config["servers"][i["name"]]["categories"]:
      category_pos += 1
      channel_pos = -1
      id = 0
      if category not in map(lambda x: x["name"], categories):
        print("Creating category: ", category)



        overwrites = {}
        if "permissions" in config["servers"][i["name"]]["categories"][category]:
          rolec = {}
          userc = {}
          cut = config["servers"][i["name"]]["categories"][category]["permissions"]
          if "roles" in cut:
            rolec = cut["roles"]
          if "users" in cut:
            userc = cut["users"]

          overwrites = build_permissions({}, roles, rolec,
                                              userc, i["id"])

        
        resp = requests.post(f"{api}/guilds/{i['id']}/channels", 
          json = {"name": category, "type": 4, "permission_overwrites": overwrites}, headers=headers).json()
        id = resp["id"]
        # print(resp)
        print(f"Created {category} with ID: ", resp["id"])
        if category_pos != resp["position"]:
          print(requests.patch(f"{api}/guilds/{i['id']}/channels", json={"id": resp["id"], "position": category_pos}, headers=headers).json())
      else:
          overwrites = {}
          channel_obj = None
          for cat in categories:
            if (cat["name"]==category or str(cat["id"])==category):
              channel_obj = cat
              break
          if "permissions" in config["servers"][i["name"]]["categories"][category]:
            rolec = {}
            userc = {}
            cut = config["servers"][i["name"]]["categories"][category]["permissions"]
            if "roles" in cut:
              rolec = cut["roles"]
            if "users" in cut:
              userc = cut["users"]
            overwrites = build_permissions(channel_obj["permission_overwrites"], roles, rolec,
                                                userc, id)
          
          if channel_obj:
            for zzz in range(len(channel_obj["permission_overwrites"])):
              if "allow_new" in channel_obj["permission_overwrites"][zzz]:
                del channel_obj["permission_overwrites"][zzz]["allow_new"]
              if "deny_new" in channel_obj["permission_overwrites"][zzz]:
                del channel_obj["permission_overwrites"][zzz]["deny_new"]
              
            set_ids = []
            for set_id in overwrites:
              set_ids.append(set_id["id"])
            for ovr in overwrites:
              if ovr["type"]=='role' and ovr["id"] not in set_ids:
                requests.delete(f"{api}/channels/{channel_obj['id']}/permissions/{ovr['id']}")
            
            patch = {}
            #print(overwrites, "::\nvs\n::\n", channel_obj["permission_overwrites"])
            if sorted(overwrites, key=lambda d: int(d['id'])) != sorted(channel_obj["permission_overwrites"], key=lambda d: int(d['id'])):
              print("UPDATING OVERWRITES FOR CATEGORY: ", category)
              patch["permission_overwrites"] = overwrites
            
            # PATCH SYNC 

            if patch!={}:
              print(requests.patch(f"{api}/channels/{channel_obj['id']}", json=patch, 
                headers=headers).json())
            
            # POSITION SYNC

            if category_pos != channel_obj["position"]:
              print(requests.patch(f"{api}/guilds/{i['id']}/channels", json={"id": channel_obj['id'], "position": category_pos}, 
                headers=headers).json())




      if id==0:
        for cat in categories:
          if cat["name"]==category:
            id = cat["id"]
            break



      for channel in config["servers"][i["name"]]["categories"][category]["channels"]:
        channel_pos += 1
        if channel not in map(lambda x: x["name"], filter( lambda x: x["parent_id"]==id, channels ) ):
          print("Creating channel: ", channel)

          
          overwrites = {}
          sync = False
          if "permissions" in config["servers"][i["name"]]["categories"][category]["channels"][channel]:
            rolec = {}
            userc = {}
            cut = config["servers"][i["name"]]["categories"][category]["channels"][channel]["permissions"]
            if "roles" in cut:
              rolec = cut["roles"]
            if "users" in cut:
              userc = cut["users"]

            overwrites = build_permissions({}, roles, rolec,
                                                userc, i["id"])          

            if "sync" in cut:
              sync = cut["sync"]



          resp = requests.post(f"{api}/guilds/{i['id']}/channels",
            json = {"name": channel, "type": 0, "parent_id": id, "permission_overwrites": overwrites}, headers=headers).json()
          if channel_pos != resp["position"]:
              print(requests.patch(f"{api}/guilds/{i['id']}/channels", 
                json={"id": resp["id"], "position": channel_pos, "lock_permissions": sync}, headers=headers).json())
        else:
          overwrites = {}
          sync = False
          channel_obj = None
          for chnl in channels:
            if (chnl["name"]==channel or str(chnl["id"])==channel) and chnl["parent_id"] == id:
              channel_obj = chnl
              break
          if "permissions" in config["servers"][i["name"]]["categories"][category]["channels"][channel]:
            rolec = {}
            userc = {}
            cut = config["servers"][i["name"]]["categories"][category]["channels"][channel]["permissions"]
            if "roles" in cut:
              rolec = cut["roles"]
            if "users" in cut:
              userc = cut["users"]
            overwrites = build_permissions(channel_obj["permission_overwrites"], roles, rolec,
                                                userc, i["id"])

            if "sync" in cut:
              sync = cut["sync"]


          if channel_obj:
            for zzz in range(len(channel_obj["permission_overwrites"])):
              if "allow_new" in channel_obj["permission_overwrites"][zzz]:
                del channel_obj["permission_overwrites"][zzz]["allow_new"]
              if "deny_new" in channel_obj["permission_overwrites"][zzz]:
                del channel_obj["permission_overwrites"][zzz]["deny_new"]
            

            set_ids = []
            for set_id in overwrites:
              set_ids.append(set_id["id"])
            for ovr in overwrites:
              if ovr["type"]=='role' and ovr["id"] not in set_ids:
                requests.delete(f"{api}/channels/{channel_obj['id']}/permissions/{ovr['id']}")


            patch = {}
            if sorted(overwrites, key=lambda d: int(d['id'])) != sorted(channel_obj["permission_overwrites"], key=lambda d: int(d['id'])):
              print("UPDATING OVERWRITES FOR CATEGORY: ", category)
              patch["permission_overwrites"] = overwrites
            
            # PATCH SYNC 

            if patch!={}:
              print(requests.patch(f"{api}/channels/{channel_obj['id']}", json=patch, 
                headers=headers).json())
            
            # POSITION SYNC

            if channel_pos != channel_obj["position"]:
              print(requests.patch(f"{api}/guilds/{i['id']}/channels", 
                json={"id": channel_obj["id"], "position": channel_pos, "lock_permissions": sync}, headers=headers).json())


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
      
      ${sync_data}/bin/discord_sync
      rm -r /tmp/discord_sync
    '';
  };
}
