@react.component
let make = (~dog) => {
  let dogs = DogxContext.useDogxContext()
  let dog = switch dogs->Js.Dict.get(dog) {
  | Some(dogComponent) => dogComponent
  | None => <div> {`No dog for "${dog}"`->React.string} </div>
  }

  <div
    style={ReactDOM.Style.make(
      ~position="relative",
      ~border="1px solid hsla(203, 50%, 30%, 0.15)",
      ~boxShadow="rgba(0, 0, 0, 0.10) 0 1px 3px 0",
      (),
    )}>
    {dog}
  </div>
}
