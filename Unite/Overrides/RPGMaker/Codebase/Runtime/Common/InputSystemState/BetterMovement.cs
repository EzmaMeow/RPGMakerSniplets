//This replaces the public function block : OnMove
//How to use: Copy this and replace all of OnMove code (and the comment above it) with this
//What this dose: It forces the player to move in the direction of the newest input
//instead of always moving right or left.
        public bool OnMoveRight(float axis)
        {
            if (axis <= -0.5)
            {
                _inputSystemState[HandleType.Left] = true;
                _latestInputDic[HandleType.Left] = true;
                _lastMoveDirection = HandleType.LeftKeyDown;
                return true;
            }
            else if (axis >= 0.5)
            {
                _inputSystemState[HandleType.Right] = true;
                _latestInputDic[HandleType.Right] = true;
                _lastMoveDirection = HandleType.RightKeyDown;
                return true;
            }
            else
            {
                _lastMoveDirection = HandleType.None;
                return false;
            }
        }
        public bool OnMoveUp(float axis)
        {
            if (axis <= -0.5)
            {
                _inputSystemState[HandleType.Down] = true;
                _latestInputDic[HandleType.Down] = true;
                _lastMoveDirection = HandleType.DownKeyDown;
                return true;
            }
            else if (axis >= 0.5)
            {
                _inputSystemState[HandleType.Up] = true;
                _latestInputDic[HandleType.Up] = true;
                _lastMoveDirection = HandleType.UpKeyDown;
                return true;
            }
            else
            {
                _lastMoveDirection = HandleType.None;
                return false;
            }
        }


        /// <summary>
        /// 十字キー
        /// </summary>
        /// <param name="context"></param>
        public void OnMove(InputAction.CallbackContext context)
        {
            //初期化
            _inputSystemState[HandleType.Left] = false;
            _inputSystemState[HandleType.Right] = false;
            _inputSystemState[HandleType.Up] = false;
            _inputSystemState[HandleType.Down] = false;

            bool _isMovingRight = _latestInputDic[HandleType.Right] || _latestInputDic[HandleType.Left];
            bool _isMovingUP = _latestInputDic[HandleType.Up] || _latestInputDic[HandleType.Down];

            _latestInputDic[HandleType.Left] = false;
            _latestInputDic[HandleType.Right] = false;
            _latestInputDic[HandleType.Up] = false;
            _latestInputDic[HandleType.Down] = false;

            //十字キーの大きさを取得
            _move = context.ReadValue<Vector2>();


            if (_isMovingUP) {
                if (!OnMoveRight(_move.x))
                {
                    OnMoveUp(_move.y);
                }
            }
            else if (_isMovingRight)
            {
                if (!OnMoveUp(_move.y))
                {
                    OnMoveRight(_move.x);
                }
            }
            else if (Mathf.Abs(_move.x) >= Mathf.Abs(_move.y))
            {
                //左右への移動
                OnMoveRight(_move.x);
            }
            else
            {
                OnMoveUp(_move.y);
            }

        }
