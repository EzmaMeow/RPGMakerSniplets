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
 * @arg eventTarget
 *      @text eventTarget
 *      @desc the target event.
 *      @type map_event 
 *      
 * @arg distance
 *      @text distance
 *      @desc distance to jump
 *      @type integer
 *      @default 1
 *      
 * @arg allowVehicle
 *      @text allowVehicle
 *      @desc If true, will allow jumping while player in a vehicle. NOTE: vehicle jumping is not supported. It make it jump, but the player orgins dose not move with it.
 *      @type boolean
 *      @default false
 *      
 * @arg checkCollision
 *      @text checkCollision
 *      @desc If true, will see if the character can move to the tile normally
 *      @type boolean
 *      @default true
 *      
 * @arg allowedTag
 *      @text allowedTag
 *      @desc allowedTag
 *      @type integer
 *      @default -1
 *      
 * @arg allowedRegion
 *      @text allowedRegion
 *      @desc allowedRegion
 *      @type integer
 *      @default -1
 */

using RPGMaker.Codebase.CoreSystem.Knowledge.DataModel.Map;
using RPGMaker.Codebase.CoreSystem.Knowledge.Enum;
using RPGMaker.Codebase.CoreSystem.Service.EventManagement;
using RPGMaker.Codebase.Runtime.Addon;
using RPGMaker.Codebase.Runtime.Battle.Window;
using RPGMaker.Codebase.Runtime.Common;
using RPGMaker.Codebase.Runtime.Common.Component.Hud.Character;
using RPGMaker.Codebase.Runtime.Map;
using RPGMaker.Codebase.Runtime.Map.Component.Character;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using TMPro;
using UnityEngine;
using UnityEngine.Tilemaps;
using UnityEngine.UIElements;
using static RPGMaker.Codebase.CoreSystem.Knowledge.DataModel.Flag.FlagDataModel;
using static UnityEditor.PlayerSettings;

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

		private Vector2Int[] directionalVector = new Vector2Int[] {
			Vector2Int.up,//Up
			Vector2Int.down,//Down
			Vector2Int.left,//Left
			Vector2Int.right,//Right
		};


		public CustomEvents(string addonPrefix)
		{
			_addonPrefix = addonPrefix;
			Debug.Log($"{addonPrefix} init");
		}

		//for getting the tag or region. this will check of all tiles so tile id would not be checked
		//type = [Terrain Tag][Event ID][Tile ID][Region ID]
		public List<string> GetCellMeta(int type = 0, Vector2Int pos = new Vector2Int())
		{
			var returnValue = new List<string>();
			if (type != 1)
			{
				foreach (var layerType in new MapDataModel.Layer.LayerType[] { MapDataModel.Layer.LayerType.A, MapDataModel.Layer.LayerType.B, MapDataModel.Layer.LayerType.C, MapDataModel.Layer.LayerType.D })
				{
#if (UNITY_EDITOR && !UNITE_WEBGL_TEST) || !UNITY_WEBGL
					var layerTilemap = MapManager.GetTileMapForRuntime(layerType);
#else
				var layerTilemap = await MapManager.GetTileMapForRuntime(layerType);
#endif
					//may remove this... it a failsafe
					if (pos.y > 0)
					{
						pos.y = -pos.y;
					}
					var tileDataModel = layerTilemap.GetTile<TileDataModel>(new Vector3Int(pos.x, pos.y, 0));
					if (tileDataModel == null)
					{
						//will return empty string so that the index will represent the layer order 
                        returnValue.Add("");
						continue;
                    }

                    switch (type)
					{
						case 0:
							{
								returnValue.Add(tileDataModel.terrainTagValue.ToString());
								break;
							}
						case 2:
							{
								returnValue.Add(tileDataModel.id);
								break;
							}
						case 3:
							{
								returnValue.Add(tileDataModel.regionId.ToString());
								break;
							}
					}
				}
			}
			else
			{
                var currentMapId = MapManager.CurrentMapDataModel.id;
#if (UNITY_EDITOR && !UNITE_WEBGL_TEST) || !UNITY_WEBGL
                var currentMapEventMapDataModels = new EventManagementService().LoadEventMap().Where(eventMapDataModel => eventMapDataModel.mapId == currentMapId);
#else
                        var currentMapEventMapDataModels = (await new EventManagementService().LoadEventMap()).Where(eventMapDataModel => eventMapDataModel.mapId == currentMapId);
#endif

                foreach (var eventMapDataModel in currentMapEventMapDataModels)
                {
                    if (eventMapDataModel.x == pos.x &&
                        System.Math.Abs(eventMapDataModel.y) == System.Math.Abs(pos.y))
                    {
                        returnValue.Add(eventMapDataModel.SerialNumberString);
                    }
                }
            }
			return returnValue;
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

		public void JumpAhead(string eventTarget, int distance, bool allowVehicle, bool checkCollision, int allowedTag, int allowedRegion)
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
			string vehicle = null;
			int x = 0;
			int y = 0;
			if (targetType == "-1")
			{
				eventObj = MapEventExecutionController.Instance.GetEventMapGameObject(eventID);
				targetID = eventID;
			}
			else if (targetType == "-2")
			{
				eventObj = MapManager.GetOperatingCharacterGameObject();
				targetID = targetType;

				if (allowVehicle)
				{
					//Need to change to null if ""
					vehicle = (MapManager.CurrentVehicleId != "") ? MapManager.CurrentVehicleId: null;

				}
				else if (!allowVehicle && (MapManager.CurrentVehicleId != null && MapManager.CurrentVehicleId != ""))
				{
					Debug.Log($"JumpAhead cancel: is in vehicle {MapManager.CurrentVehicleId}");
					return;
				}
			}
			else
			{
				eventObj = MapEventExecutionController.Instance.GetEventMapGameObject(targetID);
			}
			if (eventObj == null) {
                Debug.Log($"JumpAhead cancel: event object is null");
                return;
			}
			var stepMoveController = eventObj.GetComponent<StepMoveController>();
			if (stepMoveController == null)
			{
				stepMoveController = eventObj.AddComponent<StepMoveController>();
			}

            var eventDirection = eventObj.GetComponent<CharacterOnMap>().GetCurrentDirection();
			var direction = directionalVector[(int)eventDirection];
			Vector2Int currentPos = new Vector2Int(eventObj.GetComponent<CharacterOnMap>().x_now, eventObj.GetComponent<CharacterOnMap>().y_now);
			Vector2Int jumpPos = currentPos + (direction*distance);

			x = jumpPos.x;
			y = jumpPos.y > 0 ? jumpPos.y : -jumpPos.y; 

			var tile = MapManager.CurrentTileData(jumpPos);
			bool navigable = true;

            if (allowedTag >= 0)
			{
                var tags = GetCellMeta(0, jumpPos);
				if (!tags.Contains(allowedTag.ToString()))
				{
                    Debug.Log($"JumpAhead cancel: dose not have tag {allowedTag}");
                    navigable = false;
				}
            }
            if (allowedRegion >= 0)
            {
                var regions = GetCellMeta(3, jumpPos);
                if (!regions.Contains(allowedRegion.ToString()))
                {
                    Debug.Log($"JumpAhead cancel: dose not have region {allowedRegion}");
                    navigable = false;
                }
            }

			//end this if it normally would not be able to move.
			if (checkCollision)
			{
				if (!tile.CanEnterThisTiles(eventDirection, vehicle))
				{
					if (!navigable)
					{
						Debug.Log($"JumpAhead cancel: collsion detected and checkCollision = {checkCollision}");
						return;
					}
				}
			}
			else if (!navigable)
			{
				Debug.Log($"JumpAhead cancel: no navigable terrain = {navigable}");
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

