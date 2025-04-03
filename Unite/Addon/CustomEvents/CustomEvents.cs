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
 * @command LogMessage
 *      @text Log Output a Message
 *      @desc output a message to Unity Log Window.
 * 
 *  @arg LogMessage
 *      @text message
 *      @desc Message to display.
 *      @type string
 *      @default Message
 * 
 */

using UnityEngine;

namespace RPGMaker.Codebase.Addon
{
    public class CustomEvents
    {
        private string _addonPrefix;

        private string FormatLogMessage(string message)
        {
            return $"{_addonPrefix}: {message}";
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
    }
}
