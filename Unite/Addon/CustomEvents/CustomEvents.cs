/*:
 * @addondesc Additional events
 * @author Ezma G
 * @help Provides add-on events.
 * @version 0.0.1
 * 
 * @param addonPrefix
 * @text Debug prefix
 * @desc This is added before any debug log message sent by this addon.
 * @type string
 * @default CE 
 * 
 * @param logEventID
 * @text boolean value
 * @desc Will also prefix log message with an event id.
 * @type boolean
 * @default true
 * @on Enable
 * @off Disable
 * 
 * @command LogMessage
 *      @text Log Output a Message
 *      @desc output a message to Unity Log Window.
 * 
 *  @arg message
 *      @text message
 *      @desc Message to display.
 *      @type string
 *      @default Message
 *      
 * @command LogTest
 *      @text Log Output Test Results
 *      @desc this is for testing out logic (aka dev only)
 *      
 * @command IsMapEventsRuning
 *      @text Is Map Events Runing
 *      @desc Set the assign switch to true if there a map event running
 *      
 *  @arg switchValue
 *      @text Switch
 *      @desc The switch to use.
 *      @type switch
 *      
 */

using RPGMaker.Codebase.Runtime.Addon;
using RPGMaker.Codebase.Runtime.Common;
using RPGMaker.Codebase.Runtime.Map;
using System;
using TMPro;
using UnityEngine;

namespace RPGMaker.Codebase.Addon
{
    public class CustomEvents 
    {
        private string _addonPrefix;
        private bool _logEventID;

        private string FormatLogMessage(string message)
        {
            var eventId = AddonManager.Instance.GetCurrentEventId();
            if (eventId != null && _logEventID)
            {
                return $"{_addonPrefix}:({eventId}) {message}";
            }
            else
            {
                return $"{_addonPrefix}: {message}";
            }
        }


        public CustomEvents(string addonPrefix, bool logEventID)
        {
            _logEventID = logEventID;
            _addonPrefix = addonPrefix;
            Debug.Log($"{addonPrefix} init");
        }

        public void LogMessage(string message)
        {
            Debug.Log(FormatLogMessage(message));
        }

        public void LogTest()
        {
            Debug.Log(FormatLogMessage($"Test: RunningEvent = {MapEventExecutionController.Instance.CheckRunningEvent()}"));
        }

        public void IsMapEventsRuning(string switchValue)
        {
            bool isRunning = MapEventExecutionController.Instance.CheckRunningEvent();
            var switch_id = DataManager.Self().GetFlags().switches.FindIndex(item => item.id == switchValue);
            if (switch_id > 0) {
                var data = DataManager.Self().GetRuntimeSaveDataModel();
                data.switches.data[switch_id] = isRunning;
            }
        }

    }
}
