open Belt
module URLSearchParams = Bindings.URLSearchParams

type t = Js.Dict.t<Entity.t>

let rec demo = (demos: t, categories: list<string>, dogName: string) => {
  switch categories {
  | list{} =>
    demos
    ->Js.Dict.get(dogName)
    ->Option.flatMap(entity =>
      switch entity {
      | Demo(demoUnit) => Some(demoUnit)
      | Dogx(dogxUnit, dogs) => Some(_ => <Dogxment dogs={dogs}> {dogxUnit()} </Dogxment>)
      | _ => None
      }
    )
  | list{categoryName, ...categories} =>
    demos
    ->Js.Dict.get(categoryName)
    ->Option.flatMap(entity =>
      switch entity {
      | Category(demos) => demo(demos, categories, dogName)
      | _ => None
      }
    )
  }
}

let findDemo = (urlSearchParams: URLSearchParams.t, dog, demos: t) => {
  let categories =
    urlSearchParams
    ->URLSearchParams.toArray()
    ->List.fromArray
    ->List.keep(((key, _value)) => key->Js.String2.startsWith("category"))
    ->List.sort(((categoryNum1, _), (categoryNum2, _)) =>
      String.compare(categoryNum1, categoryNum2)
    )
    ->List.map(((_categoryNum, categoryName)) => categoryName)

  demos->demo(categories, dog)
}

let rec isNestedEntityMatchSearch = (demos: t, searchString) => {
  demos
  ->Js.Dict.entries
  ->Array.some(((entityName, entity)) => {
    let isEntityNameMatchSearch =
      HighlightTerms.getMatchingTerms(~searchString, ~entityName)->Array.size > 0
    switch entity {
    | Demo(_) => isEntityNameMatchSearch
    | Dogx(_) => isEntityNameMatchSearch
    | Category(demos) => isEntityNameMatchSearch || isNestedEntityMatchSearch(demos, searchString)
    }
  })
}
