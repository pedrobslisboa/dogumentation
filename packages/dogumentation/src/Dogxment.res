@react.component
let make = (~dogs, ~children) => {
  let dogs = dogs->Js.Dict.entries->Js.Array.filter(((_, entity)) =>
      switch entity {
      | Entity.Demo(_) => true
      | _ => false
      }
    , _)->Js.Array.map(((key, entity)) => (
      key,
      switch entity {
      | Entity.Demo(demoUnit) => <DogUnit demoUnit={demoUnit} controlsOrientation={#horizontal} />
      | _ =>
        <div style={ReactDOM.Style.make(~border="1px solid red", ())}>
          {"hello"->React.string}
        </div>
      },
    ), _)->Js.Dict.fromArray

  <div
    style={ReactDOM.Style.make(
      ~padding="10px",
      ~margin="0 auto",
      ~width="100%",
      ~maxWidth="800px",
      (),
    )}>
    <DogxContext.Provider value={dogs}> {children} </DogxContext.Provider>
  </div>
}
