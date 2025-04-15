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
 * @arg eventTarget
 *      @text eventTarget
 *      @desc the target event.
 *      @type map_event 
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
 * @arg trough
 *      @text trough
 *      @desc Allow jump with no collsion checks
 *		@type boolean
 *		@default false
 *		
 * @arg allowVehicle
 *      @text allowVehicle
 *      @desc If true, will allow jumping while player in a vehicle. NOTE: vehicle jumping is not supported.
 *      @type boolean
 *      @default false
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
 *      

 *  @command SetVariableToLocationInFrontOfEvent
 *      @text SetVariableToLocationInFrontOfEvent
 *      @desc Will store the x and y of the tile infront of the selected event
 *      
 * @arg eventTarget
 *      @text eventTarget
 *      @desc the target event.
 *      @type map_event 
 *      
 *  @arg varXID
 *      @text x
 *      @desc x
 *      @type variable
 *      
 *  @arg varYID
 *      @text y
 *      @desc y
 *      @type variable
 *      
 * @arg distance
 *      @text distance
 *      @desc distance from the character
 *      @type integer
 *      @default 1
 *      
 *	@command IsEventAtLocation
 *      @text IsEventAtLocation
 *      @desc Check if there a event(character) at the location.
 *      
 *  @arg switchID
 *      @text Switch
 *      @desc The switch to use.
 *      @type switch
 *          
 *  @arg varXID
 *      @text x
 *      @desc x
 *      @type variable
 *      
 *  @arg varYID
 *      @text y
 *      @desc y
 *      @type variable
 *      
 *	@arg isBlocking
 *      @text isBlocking
 *      @desc This checks if this event would normally block player from entering tile.
 *      @type boolean
 *      @default true
 *      
 *	@arg allowedTrigger
 *		@text allowedTrigger
 *		@desc Filter this to only be true if event also listening to this trigger.
 *		@type select
 *		@option Action
 *		@option Player_Touch
 *		@option Event_Touch
 *		@option Autorun
 *		@option Parallel_Process
 *		@option Any
 *		@default Any    
 *      
 *      
 * @command IsLocationNavigable
 *      @text IsLocationNavigable
 *      @desc Check if the location can be move to normally.
 *      
 *  @arg switchID
 *      @text Switch
 *      @desc The switch to use.
 *      @type switch
 *          
 *  @arg varXID
 *      @text x
 *      @desc x
 *      @type variable
 *      
 *  @arg varYID
 *      @text y
 *      @desc y
 *      @type variable
 *      
 *  @arg direction
 *      @text direction
 *      @desc This can be a number or up, down, left, right, or \v[#] where # is the varible id to pull the direction from
 *      @type string
 *      @default 0
 *      
 * @arg isPlayer
 *      @text isPlayer
 *      @desc This will check the player vehicle if true and player is riding it.
 *      @type boolean
 *      @default true     
 */

using RPGMaker.Codebase.CoreSystem.Knowledge.DataModel.EventMap;
using RPGMaker.Codebase.CoreSystem.Knowledge.DataModel.Map;
using RPGMaker.Codebase.CoreSystem.Knowledge.Enum;
using RPGMaker.Codebase.Runtime.Addon;
using RPGMaker.Codebase.Runtime.Common;
using RPGMaker.Codebase.Runtime.Common.Component.Hud.Character;
using RPGMaker.Codebase.Runtime.Map;
using RPGMaker.Codebase.Runtime.Map.Component.Character;
using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using UnityEngine;
using UnityEngine.Tilemaps;


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

		private MapDataModel.Layer.LayerType[] MainLayerTypes = new MapDataModel.Layer.LayerType[]
		{
			MapDataModel.Layer.LayerType.D,
			MapDataModel.Layer.LayerType.C,
			MapDataModel.Layer.LayerType.B,
			MapDataModel.Layer.LayerType.A
		};

		// Main

		public CustomEvents(string addonPrefix)
		{
			_addonPrefix = addonPrefix;
			Debug.Log($"{addonPrefix} init");
		}

		//Utility

		public CharacterMoveDirectionEnum GetDirectionEnumFromString(string directionString)
		{
			string direction = directionString;
			Match match = Regex.Match(directionString, @"\v[(\d+)]");
			if (match.Success)
			{
				int.TryParse(match.Groups[1].Value, out int variableIndex);
				if (variableIndex > 0)
				{
					direction = DataManager.Self().GetRuntimeSaveDataModel().variables.data[variableIndex].ToString();
				}
			}
			if (direction == "0" || direction == "up")
			{
				return CharacterMoveDirectionEnum.Up;
			}
			else if (direction == "1" || direction == "down")
			{
				return CharacterMoveDirectionEnum.Down;
			}
			else if (direction == "2" || direction == "left")
			{
				return CharacterMoveDirectionEnum.Left;
			}
			else if (direction == "3" || direction == "right")
			{
				return CharacterMoveDirectionEnum.Right;
			}
			else if (direction == "4" || direction == "damage")
			{
				return CharacterMoveDirectionEnum.Damage;
			}
			else if (direction == "player") {
				var eventObj = MapManager.GetOperatingCharacterGameObject();
				if (eventObj != null) 
				{
					return eventObj.GetComponent<CharacterOnMap>().GetCurrentDirection();
				}
			}
			else if (direction == "event" || direction == "this" || direction == "self")
			{
				var eventObj = MapEventExecutionController.Instance.GetEventMapGameObject(AddonManager.Instance.GetCurrentEventId());
				if (eventObj != null) 
				{
					return eventObj.GetComponent<CharacterOnMap>().GetCurrentDirection();
				}
			}
			return CharacterMoveDirectionEnum.None;
		}

		public string GetVariableValue(string variableID, string defaultValue="0")
		{
			var variableIndex = DataManager.Self().GetFlags().variables.FindIndex(item => item.id == variableID);
			if (variableIndex < 0)
			{
				return defaultValue;
			}
			return DataManager.Self().GetRuntimeSaveDataModel().variables.data[variableIndex].ToLower();
		}

		public bool HasTerrainTag(Vector2Int position, int tagID)
		{
			foreach (var layerType in MainLayerTypes)
			{
				//may need to add the await macro case for layerTilemap?
				Tilemap layerTilemap = MapManager.GetTileMapForRuntime(layerType);
				TileDataModel tileDataModel = layerTilemap.GetTile<TileDataModel>(new Vector3Int(position.x, position.y, 0));
				if (tileDataModel == null)
				{
					continue;
				}
				else if (tileDataModel.terrainTagValue == tagID)
				{
					return true;
				}
			}

			return false;
		}
		public bool IsRegionAtLocation(Vector2Int position, int regionID)
		{
			foreach (var layerType in MainLayerTypes)
			{
				//may need to add the await macro case for layerTilemap?
				Tilemap layerTilemap = MapManager.GetTileMapForRuntime(layerType);
				TileDataModel tileDataModel = layerTilemap.GetTile<TileDataModel>(new Vector3Int(position.x, position.y, 0));
				if (tileDataModel == null)
				{
					continue;
				}
				else if (tileDataModel.regionId == regionID)
				{
					return true;
				}
			}

			return false;
		}

		public EventOnMap GetEventAtLocation(Vector2Int position)
		{
			List<EventOnMap> mapEvents = MapEventExecutionController.Instance.GetEvents();
			foreach (var mapEvent in mapEvents)
			{
				if (mapEvent.IsMoving() && mapEvent.GetDestinationPositionOnTile() == position ||
						!mapEvent.IsMoving() && mapEvent.GetCurrentPositionOnTile() == position)
				{
					return mapEvent;
				}
			}
			return null;
		}


		public (GameObject obj, string id, string type) ParceEventString(string eventString)
		{
			GameObject eventObj = null;

			List<string> targetData = new List<string>(Regex.Split(eventString.Trim('[', ']'), @"[,]"));
			string targetID = targetData[0].Trim('"');
			string targetType = targetData[1].Trim('"');
			if (targetData == null)
			{
				return (eventObj, targetID, targetType);
			}
			if (targetType == "-1")
			{
				var eventID = AddonManager.Instance.GetCurrentEventId();
				eventObj = MapEventExecutionController.Instance.GetEventMapGameObject(eventID);
				targetID = eventID;
			}
			else if (targetType == "-2")
			{
				eventObj = MapManager.GetOperatingCharacterGameObject();
			}
			else
			{
				eventObj = MapEventExecutionController.Instance.GetEventMapGameObject(targetID);
			}
			if (eventObj == null)
			{
				return (eventObj, targetID, targetType);
			}
			return (eventObj, targetID, targetType);
		}

		//Events

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
			int switchIndex = DataManager.Self().GetFlags().switches.FindIndex(item => item.id == switchID);
			if (switchIndex > 0)
			{
				var data = DataManager.Self().GetRuntimeSaveDataModel();
				data.switches.data[switchIndex] = isRunning;
			}
		}

		public void SetDirectionFromVariable(string eventTarget, string variableID)
		{

			//var eventID = AddonManager.Instance.GetCurrentEventId();
			//var eventObj = MapEventExecutionController.Instance.GetEventMapGameObject(eventID);
			var direction = GetDirectionEnumFromString(GetVariableValue(variableID, "-1"));

			(GameObject obj, string id, string type) eventData = ParceEventString(eventTarget);

			if (eventData.obj == null)
			{
				return;
			}

            eventData.obj.GetComponent<CharacterOnMap>().ChangeCharacterDirection(direction, true);
		}


            public void JumpAhead(string eventTarget, int distance, bool trough, bool allowVehicle, int allowedTag, int allowedRegion)
		{
            //Note: this may act odd at borders of looping maps
			//Also this is design for only a single party member on map
			//as well as an example of how to do some stuff as a addon.
            Vector2Int direction;
			Vector2Int currentPos;
			Vector2Int jumpPos;
			string vehicle = null;

			//var targetData = new List<string>(Regex.Split(eventTarget.Trim('[', ']'), @"[,]"));

			(GameObject obj, string id, string type) eventData = ParceEventString(eventTarget);

			if (eventData.obj == null)
			{
				return;
			}
			if (eventData.type == "-2")
			{ 
				if (allowVehicle)
				{
					vehicle = (MapManager.CurrentVehicleId != "") ? MapManager.CurrentVehicleId : null;

                }
				else if (!allowVehicle && (MapManager.CurrentVehicleId != null && MapManager.CurrentVehicleId != ""))
				{
					return;
				}
			}
			var eventDirection = eventData.obj.GetComponent<CharacterOnMap>().GetCurrentDirection();
			direction = directionalVector[(int)eventDirection];
			currentPos = new Vector2Int(eventData.obj.GetComponent<CharacterOnMap>().x_next, eventData.obj.GetComponent<CharacterOnMap>().y_next);
			jumpPos = currentPos + (direction * distance);

			if (!trough)
			{
				var eventAtJump = GetEventAtLocation(jumpPos);
				if (eventAtJump != null)
				{
					if (eventAtJump.IsPriorityNormal() && !eventAtJump.GetTrough() && eventAtJump.MapDataModelEvent.temporaryErase == 0)
					{
						return;
					}
				}
				var tile = MapManager.CurrentTileData(jumpPos);
				if (!tile.CanEnterThisTiles(eventDirection, vehicle))
				{
					if ((HasTerrainTag(jumpPos, allowedTag) && allowedTag >= 0) ||
						(IsRegionAtLocation(jumpPos, allowedRegion) && allowedRegion >= 0))
					{
						//I did not feel like inverting this
					}
					else
					{
						return;
					}
				}
			}
			//Set up Step Controller for the jump
			var stepMoveController = eventData.obj.GetComponent<StepMoveController>();
			if (stepMoveController == null ) {
				stepMoveController = eventData.obj.AddComponent<StepMoveController>();
			}

			var stepTarget = eventData.type == "-2"? eventData.type : eventData.id;
#if (UNITY_EDITOR && !UNITE_WEBGL_TEST) || !UNITY_WEBGL
			stepMoveController.StartStepMove(
#else
			await stepMoveController.StartStepMove(
#endif
					AddonManager.Instance.TakeOutCommandCallback(),
					() => { stepMoveController.UpdateMove(); },
					stepTarget,
					EventMoveEnum.MOVEMENT_JUMP, jumpPos.x, jumpPos.y > 0 ? jumpPos.y : -jumpPos.y, true);
		}

		public void SetVariableToLocationInFrontOfEvent(string eventTarget,string varXID, string varYID, int distance)
		{
			(GameObject obj, string id, string type) eventData = ParceEventString(eventTarget);
			Vector2Int direction = directionalVector[(int)eventData.obj.GetComponent<CharacterOnMap>().GetCurrentDirection()];
			Vector2Int position = (new Vector2Int(eventData.obj.GetComponent<CharacterOnMap>().x_next, eventData.obj.GetComponent<CharacterOnMap>().y_next)
				+ (direction * distance));

			int varXIndex = DataManager.Self().GetFlags().variables.FindIndex(item => item.id == varXID);
			int varYIndex = DataManager.Self().GetFlags().variables.FindIndex(item => item.id == varYID);
			DataManager.Self().GetRuntimeSaveDataModel().variables.data[varXIndex] = varXIndex > 0 ? position.x.ToString() : "0";
			DataManager.Self().GetRuntimeSaveDataModel().variables.data[varYIndex] = varYIndex > 0 ? position.y.ToString() : "0";


        }

        public void IsEventAtLocation(string switchID, string varXID, string varYID, bool isBlocking, int allowedTrigger)
		{

			int.TryParse(GetVariableValue(varXID,"0"), out int x);
			int.TryParse(GetVariableValue(varYID, "0"), out int y);

			int switchIndex = DataManager.Self().GetFlags().switches.FindIndex(item => item.id == switchID);
			EventOnMap mapEvent = GetEventAtLocation(new Vector2Int(x, y > 0 ? -y : y));
			bool switchValue = false;
			if (mapEvent != null)
			{
				if (!isBlocking)
				{
					//if an event is erase (not = 0), it should be treated as not there
					switchValue = mapEvent.MapDataModelEvent.temporaryErase == 0;
					mapEvent.LookToPlayerDirection();
                }
				else
				{
					switchValue = mapEvent.IsPriorityNormal() && !mapEvent.GetTrough() && mapEvent.MapDataModelEvent.temporaryErase == 0;
				}
			}
			
			if (switchValue && allowedTrigger < 5)
			{
                int triggerid = mapEvent.page >= 0 ? mapEvent.MapDataModelEvent.pages[mapEvent.page].eventTrigger : -1;
				switchValue = allowedTrigger == triggerid;
            }
			if (switchIndex > 0)
			{
				DataManager.Self().GetRuntimeSaveDataModel().switches.data[switchIndex] = switchValue;
			}

		}

		public void IsLocationNavigable(string switchID, string varXID, string varYID, string direction, bool isPlayer)
		{
			int.TryParse(GetVariableValue(varXID, "0"), out int x);
			int.TryParse(GetVariableValue(varYID, "0"), out int y);
			int switchIndex = DataManager.Self().GetFlags().switches.FindIndex(item => item.id == switchID);
			bool switchValue = false;
			var tile = MapManager.CurrentTileData(new Vector2Int(x, y > 0 ? -y : y));
			string vehicle = null;
			if (isPlayer) {
				vehicle = (MapManager.CurrentVehicleId != "") ? MapManager.CurrentVehicleId : null;
			}

			if (tile.CanEnterThisTiles(GetDirectionEnumFromString(direction), vehicle))
			{
				switchValue = true;
			}
			DataManager.Self().GetRuntimeSaveDataModel().switches.data[switchIndex] = switchValue;
		}
	}
}
