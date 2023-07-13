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
module LocalStorage = {
  type t
  @return(nullable) @send external getItem: (t, string) => option<string> = "getItem"
  @send external setItem: (t, string, string) => unit = "setItem"
  @send external removeItem: (t, string) => unit = "removeItem"
  @val external localStorage: t = "localStorage"
}
