/*:
 * @addondesc Localization Events
 * @author Ezma G
 * @help Provides events to pull Localize text from csv files.
 * @version 0.0.1
 * 
 * @command clearCatchedLocalizeData
 *      @text Free Catched Localize Data
 *      @desc Clears the localization catch. This is to reduce catch size.
 *      
 * @command LoadLocalizeData
 *      @text Load Localize Data
 *      @desc Loads localize data. This is for preloading data.
 *      
 *  @arg file
 *      @text file
 *      @desc The csv file to use.
 *      @type string
 *      @default Default.csv
 *      
 * @command LogLocalizeString
 *      @text Log Localize String
 *      @desc Log the localized string
 *      
 *  @arg key
 *      @text key
 *      @desc The id of the term
 *      @type string
 *      @default default   
 *   
 *  @arg file
 *      @text file
 *      @desc The csv file to use.
 *      @type string
 *      @default Default.csv
 *      
 *  @arg catchData
 *      @text catchData
 *      @desc Catch the data to be easier to acess later.
 *      @type boolean
 *      @default true
 *      
 * @command ShowText
 *      @text Set the next message text
 *      @desc Set the next message text (if its text feild is left empty)
 *      
 *  @arg key
 *      @text key
 *      @desc The id of the term
 *      @type string
 *      @default default
 *   
 *  @arg file
 *      @text file
 *      @desc The csv file to use.
 *      @type string
 *      @default Default.csv
 *      
 *  @arg catchData
 *      @text catchData
 *      @desc Catch the data to be easier to acess later.
 *      @type boolean
 *      @default true
 *      
 *  @arg actor
 *      @text actor
 *      @desc The actor to pull display info from
 *      @type actor 
 *   
 *  @arg showName
 *      @text showName
 *      @desc Show the name box
 *      @type boolean
 *      @default true
 *      
 *  @arg faceType
 *      @text faceType
 *      @desc Pick the display type for the face
 *      @type select
 *      @option None
 *      @option Face
 *      @option Picture
 *      @default Face
 *      
 *  @arg name
 *      @text name
 *      @desc The name to display if there no actor set
 *      @type string
 *      
 *  @arg imageFileName
 *      @text imageFileName
 *      @desc This is the image to display. use the images in faces if icon is selected or pictures if picture is set. 
 *      @type string
 *      
 */

using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using RPGMaker.Codebase.CoreSystem.Knowledge.DataModel.CharacterActor;
using RPGMaker.Codebase.Runtime.Addon;
using RPGMaker.Codebase.Runtime.Battle.Window;
using RPGMaker.Codebase.Runtime.Common;
using RPGMaker.Codebase.Runtime.Common.Component.Hud;
using RPGMaker.Codebase.Runtime.Common.Enum;
using RPGMaker.Codebase.Runtime.Event;
using UnityEngine;
using static UnityEditor.Experimental.AssetDatabaseExperimental.AssetDatabaseCounters;

namespace RPGMaker.Codebase.Addon
{
    public class LocalizationEvents 
    {
        public Dictionary<string, Dictionary<string, string[]>> catchedLocalizeData;
        private Action _callback;

        //Note: could also limit it to only load the current langauge to save space, but catch need to
        //be clear on language change
        private Dictionary<string, string[]> GetLocalizeData(string file, bool catchData = true)
        {
            string path = Path.Combine(Application.dataPath, "Localization", file);
            Dictionary<string, string[]> localizeData = new Dictionary<string, string[]>();

            if (catchedLocalizeData.ContainsKey(file))
            {
                Debug.Log($"{path} exists in catch");
                return catchedLocalizeData[file];
            }
            Debug.Log($"{path} exists: {File.Exists(path)}");
            if (File.Exists(path))
            {
                try
                {
                    using (StreamReader streamReader = new StreamReader(path))
                    {
                        string line;
                        string pattern = @"(?:^|,)(?:""(?<value>(?:[^""]|"""")*)""|(?<value>[^,]*))";
                        while ((line = streamReader.ReadLine()) != null)
                        {
                            string[] row = null;
                            var matches = Regex.Matches(line, pattern);
                            var fields = new List<string>();
                            foreach (Match match in matches)
                            {
                                fields.Add(match.Groups["value"].Value.Replace("\"\"", "\""));
                            }
                            row = fields.ToArray();
                            if (row[0] != null)
                            {
                                localizeData[row[0]] = row.Skip(1).ToArray();
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    Debug.LogError("Error reading CSV file: " + e.Message);
                }
            }
            if (catchData)
            {
                catchedLocalizeData[file] = localizeData;
            }
            return localizeData;
        }

        private void DecideEvent()
        {
            //Debug.Log($"input");
            if (HudDistributor.Instance.NowHudHandler().IsInputWait())
            {
                HudDistributor.Instance.NowHudHandler().Next();
                return;
            }
            if (!HudDistributor.Instance.NowHudHandler().IsInputEnd())
            {
                return;
            }

            InputDistributor.RemoveInputHandler(GameStateHandler.IsMap() ? GameStateHandler.GameState.EVENT : GameStateHandler.GameState.BATTLE_EVENT, HandleType.Decide, DecideEvent);
            InputDistributor.RemoveInputHandler(GameStateHandler.IsMap() ? GameStateHandler.GameState.EVENT : GameStateHandler.GameState.BATTLE_EVENT, HandleType.LeftClick, DecideEvent);

            //Below is incase we are going to handle multi pages
            //if (_messages.Count > 0)
            //{
                  //This will need to be change to a function that set to the window for our case
            //    TimeHandler.Instance.AddTimeActionFrame(1, ShowLevelupWindow, false);
            //}
            //else
            //{
            //    HudDistributor.Instance.NowHudHandler().CloseMessageWindow();
            //    callback();
            //}
            HudDistributor.Instance.NowHudHandler().CloseMessageWindow();
            if (_callback != null)
            {
                //Debug.Log($"ending");
                _callback();
            }
        }

        public LocalizationEvents()
        {
            catchedLocalizeData = new Dictionary<string, Dictionary<string, string[]>>();
        }

        public string GetLocalizeString(string key, string file, bool catchData = true)
        {
            //NOTE: THIS NEED TO READ THE LANGUAGE and pick an element from
            //the array instead of joining it. First line should be reserve for
            //locale keys. it may use the Key id, but I am not sure of the key I would used. maybe locale_key
            var data = GetLocalizeData(file, true);
            string localizeString = "";
            if (data != null)
            {
                if (data.ContainsKey(key))
                {
                    localizeString = string.Join(", ", data[key]);
                    Debug.Log($"key: {key} | value: localizeString");
                }
            }
            return localizeString;
        }

        public void clearCatchedLocalizeData()
        {
            catchedLocalizeData.Clear();
        }

        public void LoadLocalizeData(string file)
        {
            GetLocalizeData(file, true);
        }

        public void LogLocalizeString(string key, string file, bool catchData)
        {
            string localeString = GetLocalizeString(key,file,catchData);
            //Debug.Log($"key: {key}, string: {localeString}");
        }


        
        public void ShowText(string key, string file, bool catchData,
            string actor, bool showName, Int32 faceType, string name, string imageFileName)
        {
            Debug.Log($"test|| actor = {actor}, showName ={showName}, faceType ={faceType}, name = {name}, face = {imageFileName}");

            var current_name = name;
            var current_icon = imageFileName;
            var current_picture = imageFileName;
            if (actor != "")
            {
                
                bool flg = false;
                var runtimeActorDataModels = DataManager.Self().GetRuntimeSaveDataModel().runtimeActorDataModels;
                for (var i = 0; i < runtimeActorDataModels.Count; i++)
                {
                    if (runtimeActorDataModels[i].actorId == actor)
                    {
                        current_name = runtimeActorDataModels[i].name;
                        current_icon = runtimeActorDataModels[i].faceImage;
                        current_picture = runtimeActorDataModels[i].advImage;
                        flg = true;
                        break;
                    }
                }
                if (!flg)
                {
                    //アクターIDが指定されているが、RuntimeActorDataModelには存在しない
                    //このケースでは、マスタデータから検索する
                    CharacterActorDataModel data = DataManager.Self().GetActorDataModel(actor);
                    if (data != null)
                    {
                        current_name = data.basic.name;
                        current_icon = data.image.face;
                        current_picture = data.image.adv;
                    }
                }
            }

            string localeString = GetLocalizeString(key, file, catchData);
            var eventId = AddonManager.Instance.GetCurrentEventId();
            //need to set this as a class var else other functions may get a null ref
            //also it should be null after the event? else could null it if not.
            _callback = AddonManager.Instance.TakeOutCommandCallback();

            HudDistributor.Instance.NowHudHandler().OpenMessageWindow();
            HudDistributor.Instance.NowHudHandler().SetShowMessage(localeString);

            if (showName)
            {
                HudDistributor.Instance.NowHudHandler().ShowName(current_name);
            }
            if (faceType == 1)
            {
                if (current_icon != "" && current_icon != "0")
                {
                    HudDistributor.Instance.NowHudHandler().ShowFaceIcon(current_icon);
                }
            }
            else if (faceType == 2)
            {
                if (current_picture != "" && current_picture != "0")
                {
                    HudDistributor.Instance.NowHudHandler().ShowPicture(current_picture);
                }
            }

            //line 217 in ActorChangeExp use this to listen to input
            InputDistributor.AddInputHandler(GameStateHandler.IsMap() ? GameStateHandler.GameState.EVENT : GameStateHandler.GameState.BATTLE_EVENT, HandleType.Decide, DecideEvent);
            InputDistributor.AddInputHandler(GameStateHandler.IsMap() ? GameStateHandler.GameState.EVENT : GameStateHandler.GameState.BATTLE_EVENT, HandleType.LeftClick, DecideEvent);

            //Debug.Log($"message is set up");

        }

    }
}  
