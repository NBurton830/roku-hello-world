'
' This is the main entry point for the screensaver.
' It creates a SceneGraph screen and displays the MainScene component.
'
Function RunScreenSaver(args as Object) as Object
  ' Create the main scene and set it as the channel's focus.
  ' The args parameter is required by the function signature, but it is not
  ' used in this implementation. This line prevents an "unused variable" warning.
  args = args

  screen = CreateObject("roSGScreen")
  port = CreateObject("roMessagePort")
  screen.SetMessagePort(port)
  
  screen.CreateScene("MainScene")
  
  ' Display the scene.
  screen.show()
  
  ' Start the event loop to keep the screensaver running until the user exits.
  while true
    msg = wait(0, port)
    msgType = type(msg)
    if msgType = "roSGScreenEvent"
      if msg.isScreenClosed()
        exit while
      end if
    end if
  end while
  return invalid
End Function