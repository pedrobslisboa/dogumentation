module URLSearchParams = {
  type t

  @new
  external make: string => t = "URLSearchParams"

  @return(nullable) @send
  external get: (t, string) => option<string> = "get"

  @send
  external forEach: (t, (string, string) => unit) => unit = "forEach"

  let toArray = (t, ()) => {
    let array = []
    t->forEach((value, key) => Js.Array2.push(array, (key, value))->ignore)
    array
  }
}

module Window = {
  module Message = {
    type t = RightSidebarDisplayed | ControlsDisplayed

    let toString = (message: t) =>
      switch message {
      | RightSidebarDisplayed => "RightSidebarDisplayed"
      | ControlsDisplayed => "ControlsDisplayed"
      }

    let fromStringOpt = (string): option<t> =>
      switch string {
      | "RightSidebarDisplayed" => Some(RightSidebarDisplayed)
      | "ControlsDisplayed" => Some(ControlsDisplayed)
      | _ => None
      }
  }

  @val external window: {..} = "window"

  let addMessageListener = (func: Js.t<'a> => unit): unit =>
    window["addEventListener"](. "message", func, false)

  let postMessage = (window, message: Message.t) =>
    window["postMessage"](. message->Message.toString, "*")

  module Iframe = {
    let contentWindow = () =>
      window["parent"]["document"]["querySelector"](. "iframe")["contentWindow"]

    let addMessageListener = (func: Js.t<'a> => unit): unit =>
      contentWindow()["addEventListener"](. "message", func, false)
  }
}

module LocalStorage = {
  type t
  @return(nullable) @send external getItem: (t, string) => option<string> = "getItem"
  @send external setItem: (t, string, string) => unit = "setItem"
  @send external removeItem: (t, string) => unit = "removeItem"
  @val external localStorage: t = "localStorage"
}
