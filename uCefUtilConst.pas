unit uCefUtilConst;

interface

const
  MYAPP_CEF_MESSAGE_NAME = 'cefappmsg';

  //IDX_DEBUG  = 0;
  IDX_TYPE   = 0;

  IDX_EVENT  = 2;
  IDX_RESULT = 3;
  IDX_VALUE  = 4;
  IDX_ID     = 5;
  IDX_NAME   = 6;
  IDX_ATTR   = 7;
  IDX_LEFT   = 8;
  IDX_TOP    = 9;
  IDX_RIGHT  = 10;
  IDX_BOTTOM = 11;
  IDX_X      = 12;
  IDX_Y      = 13;
  IDX_WIDTH  = 14;
  IDX_HEIGHT = 15;
  IDX_TAG    = 16;
  IDX_CLASS  = 17;
  IDX_VALUE2 = 18;

  IDX_CLICK_CALLBACKID = 1;
  IDX_CLICK_X = 2;
  IDX_CLICK_Y = 3;

  IDX_KEY_CALLBACKID = 1;
  IDX_KEY_CODE = 2;

  IDX_CALLBACK_ID = 1;

  KEY_TAG    = '_TAG_';

  VAL_TEST_ID_EXISTS      = 1;
  VAL_SET_VALUE_BY_ID     = 2;
  VAL_SET_VALUE_BY_NAME   = 3;
  VAL_SET_ATTR_BY_NAME    = 4;
  VAL_GET_WINDOW_RECT     = 5;
  VAL_GET_ELEMENT_RECT    = 6;
  VAL_TEST_ELEMENT_EXISTS = 7;
  VAL_GET_BIDY_RECT       = 8;
  VAL_GET_ELEMENT_TEXT    = 9;
  VAL_SET_ELEMENT_VALUE   = 10;
  VAL_SET_SELECT_VALUE    = 11;
  VAL_GET_ELEMENTS_ATTR   = 12;

  VAL_EXEC_CALLBACK = 13;
  VAL_CLICK_XY      = 14;
  VAL_FOCUSCLICK_XY = 15;
  VAL_KEY_PRESS     = 16;

  VAL_NOTIFY_STR = 17;


  SPEED_DEF = 1000;
  SCROLL_WAIT = 3333;
  CEF_EVENT_WAIT_TIMEOUT = 100000 {//debug} * 100;
  TIMEOUT_DEF = 60 * 1000;
  NAV_WAIT_TIMEOUT = 5 * 1000;
  SCREEN_WAIT_TIMEOUT = 10 * 1000;

implementation

end.
