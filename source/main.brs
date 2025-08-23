'
' This is the main entry point for the channel.
' It creates a SceneGraph screen and displays the MainScene component.
'
Sub Main()
  ' Create the main scene and set it as the channel's focus.
  screen = CreateObject("roSGScreen")
  m.port = CreateObject("roMessagePort")
  screen.SetMessagePort(m.port)
  
  ' Create the main component, which contains our "Hello, World!" text.
  m.scene = screen.CreateScene("MainScene")
  
  ' Display the scene.
  screen.show()
  
  ' Start the event loop to keep the channel running until the user exits.
  while true
    msg = wait(0, m.port)
    if type(msg) = "roSGScreenEvent"
      if msg.isScreenClosed()
        exit while
      end if
    end if
  end while
End Sub