type rec addFunctions = {
  addDog: (string, Controls.demoUnitProps => React.element) => unit,
  addToSubCategory: (
    string,
    addFunctions => unit,
    ~decorators: array<(React.element, DogumentationUi.context) => React.element>=?,
    unit,
  ) => unit,
  addDogx: (string, unit => React.element) => unit,
}

let decorateStory = (
  decorators,
  dog: React.element,
  context: DogumentationUi.context,
): React.element => {
  decorators->Js.Array.reduce((acc, decorator) => {
    decorator(acc, context)
  }, dog, _)
}

let rootMap: Demos.t = Js.Dict.empty()

let internalAddDemo = (demoName: string, demoUnit: Controls.demoUnitProps => React.element) => {
  rootMap->Js.Dict.set(demoName, Demo(demoUnit))
}

let rec internaladdToCategory = (
  categoryName: string,
  func: addFunctions => unit,
  ~decorators as internalDecorators: option<
    array<(React.element, DogumentationUi.context) => React.element>,
  >=?,
  ~prevMap: Demos.t,
) => {
  let category = ref(Js.Dict.empty())

  switch prevMap->Js.Dict.get(categoryName) {
  | Some(valeu) =>
    switch valeu {
    | Category(v) => category := v
    | _ => ()
    }
  | None => prevMap->Js.Dict.set(categoryName, Category(category.contents))
  }

  let newAddDemo = (demoName: string, demoUnit: Controls.demoUnitProps => React.element) => {
    let decorators = switch internalDecorators {
    | Some(decorators) => decorators
    | None => []
    }

    category.contents->Js.Dict.set(
      demoName,
      Demo(
        controls => {
          decorateStory(decorators, demoUnit(controls), {controls: controls})
        },
      ),
    )
  }

  let addDogx = (dogxName: string, dogxUnit: unit => React.element) => {
    category.contents->Js.Dict.set(dogxName, Dogx(dogxUnit, category.contents))
  }

  let newFunctions = {
    addDog: newAddDemo,
    addToSubCategory: (a, b, ~decorators=[], ()) => {
      internaladdToCategory(
        a,
        b,
        ~decorators=Belt.Array.concatMany([
          switch internalDecorators {
          | Some(value) => value
          | None => []
          },
          decorators,
        ]),
        ~prevMap=category.contents,
      )
    },
    addDogx,
  }

  func(newFunctions)
}

let addToCategory = (a, b, ~decorators=[], ()) =>
  internaladdToCategory(a, b, ~decorators, ~prevMap=rootMap)
