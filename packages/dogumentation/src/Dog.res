type rec addFunctions = {
  addDog: (string, Controls.demoUnitProps => React.element) => unit,
  addToSubCategory: (string, addFunctions => unit) => unit,
}

let rootMap: Demos.t = Js.Dict.empty()

let internalAddDemo = (demoName: string, demoUnit: Controls.demoUnitProps => React.element) => {
  rootMap->Js.Dict.set(demoName, Demo(demoUnit))
}

let rec internaladdToCategory = (
  categoryName: string,
  func: addFunctions => unit,
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
    category.contents->Js.Dict.set(demoName, Demo(demoUnit))
  }

  let newFunctions = {
    addDog: newAddDemo,
    addToSubCategory: (a, b) => internaladdToCategory(a, b, ~prevMap=category.contents),
  }

  func(newFunctions)
}

let addToCategory = (a, b) => internaladdToCategory(a, b, ~prevMap=rootMap)
