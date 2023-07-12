type config = {
  intro?: React.element,
  logo?: string,
  sortDogs?: ((string, Entity.t), (string, Entity.t)) => int,
  decorators?: array<(React.element, DogumentationUi.context) => React.element>,
}

let decorateStory = (decorators, dog, context) => {
  decorators->Js.Array.reduce((acc, decorator) => {
    decorator(acc, context)
  }, dog, _)
}

let configInitialValue: config = {}

let start = (~config=configInitialValue, ()) => {
  let intro = switch config.intro {
  | Some(i) => Some(i)
  | None => None
  }

  switch ReactDOM.querySelector("#root") {
  | Some(rootEl) => {
      let root = ReactDOM.Client.createRoot(rootEl)

      ReactDOM.Client.Root.render(
        root,
        <DogumentationUi.App
          logo=config.logo
          demos=Dog.rootMap
          intro
          sortDogs=config.sortDogs
          applyDecorators={switch config.decorators {
          | Some(decorators) => (dog, context) => decorateStory(decorators, dog, context)
          | None => (dog, _) => dog
          }}
        />,
      )
    }
  | None => ()
  }
}
