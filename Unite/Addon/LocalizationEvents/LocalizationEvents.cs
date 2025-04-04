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
 *      @text Show Text
 *      @desc Show Text
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
 */

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using RPGMaker.Codebase.Runtime.Common;
using UnityEngine;

namespace RPGMaker.Codebase.Addon
{
    public class LocalizationEvents
    {
        private Dictionary<string, Dictionary<string, string[]>> catchedLocalizeData;

        //Note: could also limit it to only load the current langauge to save space, but catch need to
        //be clear on language change
        private Dictionary<string, string[]> GetLocalizeData(string file, bool catchData = true)
        {
            string path = Path.Combine(Application.dataPath, "Localization", file);
            Dictionary<string, string[]> localizeData = new Dictionary<string, string[]>();

            if (catchedLocalizeData.ContainsKey(file))
            {
                return catchedLocalizeData[file];
            }
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

        private string GetLocalizeString(string key, string file, bool catchData = true)
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
                }
            }
            return localizeString;
        }


        public LocalizationEvents()
        {
            catchedLocalizeData = new Dictionary<string, Dictionary<string, string[]>>();
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

        public void ShowText(string key, string file, bool catchData)
        {
            //Note: Currently unable to pause. A dirty trick is to add a ShowText
            //event with no text after this. It will make the game wait for input
            //and forward the text
            string localeString = GetLocalizeString(key, file, catchData);

            if (!HudDistributor.Instance.NowHudHandler().IsMessageWindowActive())
            {
                #if (UNITY_EDITOR && !UNITE_WEBGL_TEST) || !UNITY_WEBGL

                HudDistributor.Instance.NowHudHandler().OpenMessageWindow();
                #else
                await HudDistributor.Instance.NowHudHandler().OpenMessageWindow();
                #endif
                HudDistributor.Instance.NowHudHandler().SetShowMessage(localeString);
            }
            

        }

    }
}  
