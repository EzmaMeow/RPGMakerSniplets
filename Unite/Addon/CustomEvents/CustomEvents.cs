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
 *  @arg switchID
 *      @text Switch
 *      @desc The switch to use.
 *      @type switch
 *      
 *  @command SetDirectionFromVariable
 *      @text SetDirectionFromVariable
 *      @desc Set this character direction from a variable.
 *      
 *  @arg variableID
 *      @text Variable 
 *      @desc The variable to use.
 *      @type variable   
 *      
 *  @command JumpAhead
 *      @text JumpAhead
 *      @desc Jump Ahead
 *      
 *  @arg eventTarget
 *      @text eventTarget
 *      @desc the target event.
 *      @type map_event   
 */

using RPGMaker.Codebase.CoreSystem.Knowledge.Enum;
using RPGMaker.Codebase.Runtime.Addon;
using RPGMaker.Codebase.Runtime.Common;
using RPGMaker.Codebase.Runtime.Common.Component.Hud.Character;
using RPGMaker.Codebase.Runtime.Map;
using RPGMaker.Codebase.Runtime.Map.Component.Character;
using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using TMPro;
using UnityEngine;
using UnityEngine.Tilemaps;
using UnityEngine.UIElements;
using static RPGMaker.Codebase.CoreSystem.Knowledge.DataModel.Flag.FlagDataModel;

namespace RPGMaker.Codebase.Addon
{
    public class CustomEvents
    {
        private string _addonPrefix;

        private string FormatLogMessage(string message, bool logEventID = false)
        {
            var eventId = AddonManager.Instance.GetCurrentEventId();
            if (eventId != null && logEventID)
            {
                return $"{_addonPrefix}:({eventId}) {message}";
            }
            else
            {
                return $"{_addonPrefix}: {message}";
            }
        }


        public CustomEvents(string addonPrefix)
        {
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

        public void IsMapEventsRuning(string switchID)
        {
            bool isRunning = MapEventExecutionController.Instance.CheckRunningEvent();
            var switchIndex = DataManager.Self().GetFlags().switches.FindIndex(item => item.id == switchID);
            if (switchIndex > 0)
            {
                var data = DataManager.Self().GetRuntimeSaveDataModel();
                data.switches.data[switchIndex] = isRunning;
            }
        }

        public CharacterMoveDirectionEnum GetDirectionFromVariable(string variableID)
        {
            var data = DataManager.Self().GetRuntimeSaveDataModel();
            var variableIndex = DataManager.Self().GetFlags().variables.FindIndex(item => item.id == variableID);
            if (variableIndex < 0)
            {
                Debug.Log(FormatLogMessage($"Invaild Direction"));
                return CharacterMoveDirectionEnum.None;
            }
            var variableValue = data.variables.data[variableIndex].ToLower();
            if (variableValue == "0" || variableValue == "up")
            {
                return CharacterMoveDirectionEnum.Up;
            }
            else if (variableValue == "1" || variableValue == "down")
            {
                return CharacterMoveDirectionEnum.Down;
            }
            else if (variableValue == "2" || variableValue == "left")
            {
                return CharacterMoveDirectionEnum.Left;
            }
            else if (variableValue == "3" || variableValue == "right")
            {
                return CharacterMoveDirectionEnum.Right;
            }
            else if (variableValue == "4" || variableValue == "damage")
            {
                return CharacterMoveDirectionEnum.Damage;
            }
            else
            {
                Debug.Log(FormatLogMessage($"Invaild Direction"));
            }
            return CharacterMoveDirectionEnum.None;
        }

        public void SetDirectionFromVariable(string variableID)
        {
            var eventID = AddonManager.Instance.GetCurrentEventId();
            var eventObj = MapEventExecutionController.Instance.GetEventMapGameObject(eventID);
            Debug.Log($"direction: {GetDirectionFromVariable(variableID)}");
            eventObj.GetComponent<CharacterOnMap>().ChangeCharacterDirection(GetDirectionFromVariable(variableID), true);
        }

        //Note: this dose not check if vehicle can jump. 
        public void JumpAhead(string eventTarget)
        {
            GameObject eventObj = null;
            var targetData = new List<string>(Regex.Split(eventTarget.Trim('[', ']'), @"[,]"));
            
            if (targetData == null)
            {
                return;
            }
            var eventID = AddonManager.Instance.GetCurrentEventId();
            var targetID = targetData[0].Trim('"');
            var targetType = targetData[1].Trim('"');
            var vehicle = "";
            int x = 0;
            int y = 0;
            if(targetType == "-1")
            {
                eventObj = MapEventExecutionController.Instance.GetEventMapGameObject(eventID);
                targetID = eventID;
            }
            else if (targetType == "-2")
            {
                Debug.Log($"is player");
                eventObj = MapManager.GetOperatingCharacterGameObject();
                targetID = targetType;

                vehicle = MapManager.CurrentVehicleId;


            }
            else
            {
                Debug.Log($"is not player");
                eventObj = MapEventExecutionController.Instance.GetEventMapGameObject(targetID);
            }
            Debug.Log($"eventid = {eventID}");
            if (eventObj == null) {
                Debug.Log($"error");
                return;
            }
            var stepMoveController = eventObj.GetComponent<StepMoveController>();
            if (stepMoveController == null)
            {
                stepMoveController = eventObj.AddComponent<StepMoveController>();
            }
            Vector2[] directionEnumVector2 = new Vector2[] {
                Vector2.down,//Up
                Vector2.up,//Down
                Vector2.left,//Left
                Vector2.right,//Right
            };
            var eventDirection = eventObj.GetComponent<CharacterOnMap>().GetCurrentDirection();
            var direction = directionEnumVector2[(int)eventDirection];
            x = Math.Abs(eventObj.GetComponent<CharacterOnMap>().x_now) + (int)direction.x;
            y = Math.Abs(eventObj.GetComponent<CharacterOnMap>().y_now) + (int)direction.y;
            var tile = MapManager.CurrentTileData(new Vector2(eventObj.GetComponent<CharacterOnMap>().x_now + (int)direction.x, eventObj.GetComponent<CharacterOnMap>().y_now - (int)direction.y));

            //end this if it normally would not be able to move.
            if (!tile.CanEnterThisTiles(eventDirection, (vehicle == "" ? null : vehicle)))
            {
                return;
            }

#if (UNITY_EDITOR && !UNITE_WEBGL_TEST) || !UNITY_WEBGL
            stepMoveController.StartStepMove(
#else
            await stepMoveController.StartStepMove(
#endif
                    AddonManager.Instance.TakeOutCommandCallback(),
                    () => { stepMoveController.UpdateMove(); },
                    targetID,
                    EventMoveEnum.MOVEMENT_JUMP, x,y, true);
        }
    }
}
