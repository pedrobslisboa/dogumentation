@module("./dog.png")
external dogImage: string = "default"
@module("./dogx.png")
external dogxImage: string = "default"

open Belt
type context = {controls: Controls.demoUnitProps}

module Gap = Theme.Gap
module Color = Theme.Color
module Border = Theme.Border
module BorderRadius = Theme.BorderRadius
module FontSize = Theme.FontSize
module URLSearchParams = Bindings.URLSearchParams
module Window = Bindings.Window
module LocalStorage = Bindings.LocalStorage
module Array = Js.Array2

let rightSidebarId = "rightSidebar"

module DemoListSidebar = {
  module Styles = {
    let categoryName = ReactDOM.Style.make(
      ~padding=`${Gap.xs} ${Gap.xxs}`,
      ~fontSize=FontSize.md,
      ~fontWeight="500",
      (),
    )

    let link = ReactDOM.Style.make(
      ~textDecoration="none",
      ~color=Color.blue,
      ~display="block",
      ~padding=`${Gap.xs} ${Gap.md}`,
      ~borderRadius=BorderRadius.default,
      ~fontSize=FontSize.md,
      ~fontWeight="500",
      (),
    )

    let dogxLink = ReactDOM.Style.make(
      ~textDecoration="none",
      ~color=Color.orange,
      ~display="block",
      ~padding=`${Gap.xs} ${Gap.md}`,
      ~borderRadius=BorderRadius.default,
      ~fontSize=FontSize.md,
      ~fontWeight="500",
      (),
    )

    let button = ReactDOM.Style.make(
      ~height="32px",
      ~width="48px",
      ~cursor="pointer",
      ~fontSize=FontSize.sm,
      ~backgroundColor=Color.lightGray,
      ~color=Color.darkGray,
      ~border="none",
      ~margin="0",
      ~padding="0",
      ~display="flex",
      ~alignItems="center",
      ~justifyContent="center",
      (),
    )

    let activeLink = ReactDOM.Style.make(~backgroundColor=Color.midGray, ())

    let introLink = ReactDOM.Style.make(~padding=`${Gap.xs} ${Gap.md}`, ())
  }

  module SearchInput = {
    module Styles = {
      let clearButton = ReactDOM.Style.make(
        ~position="absolute",
        ~right="7px",
        ~display="flex",
        ~cursor="pointer",
        ~border="none",
        ~padding="0",
        ~backgroundColor=Color.transparent,
        ~top="50%",
        ~transform="translateY(-50%)",
        ~margin="0",
        (),
      )

      let inputWrapper = ReactDOM.Style.make(
        ~position="relative",
        ~display="flex",
        ~alignItems="center",
        ~backgroundColor=Color.midGray,
        ~borderRadius=BorderRadius.default,
        (),
      )

      let input = ReactDOM.Style.make(
        ~padding=`${Gap.xs} ${Gap.md}`,
        ~width="100%",
        ~margin="0",
        ~height="32px",
        ~boxSizing="border-box",
        ~fontFamily="inherit",
        ~fontSize=FontSize.md,
        ~border="none",
        ~backgroundColor=Color.transparent,
        ~borderRadius=BorderRadius.default,
        (),
      )
    }

    module ClearButton = {
      @react.component
      let make = (~onClear) =>
        <button style=Styles.clearButton onClick={_event => onClear()}> Icon.close </button>
    }

    @react.component
    let make = (~value, ~onChange, ~onClear) =>
      <div style=Styles.inputWrapper>
        <input style=Styles.input placeholder="Search" value onChange />
        {value == "" ? React.null : <ClearButton onClear />}
      </div>
  }

  let renderMenu = (
    ~urlSearchParams: URLSearchParams.t,
    ~searchString,
    ~sortDogs: option<((string, Entity.t), (string, Entity.t)) => int>,
    demos: Demos.t,
  ) => {
    let rec renderMenu = (
      ~parentCategoryMatchedSearch: bool,
      ~nestingLevel,
      ~categoryQuery,
      demos: Demos.t,
    ) => {
      let renderedDemos =
        demos
        ->Js.Dict.entries
        ->Belt.SortArray.stableSortBy(((a, aEntity), (b, bEntity)) => {
          switch sortDogs {
          | Some(sortDogs) => sortDogs((a, aEntity), (b, bEntity))
          | None => 0
          }
        })
        ->Array.map(((entityName, entity)) => {
          let searchMatchingTerms = HighlightTerms.getMatchingTerms(~searchString, ~entityName)
          let isEntityNameMatchSearch =
            searchString == "" || searchMatchingTerms->Belt.Array.size > 0
          switch entity {
          | Demo(_) =>
            if isEntityNameMatchSearch || parentCategoryMatchedSearch {
              <Link
                key={entityName}
                style=Styles.link
                activeStyle=Styles.activeLink
                href={"/?dog=" ++ entityName->Js.Global.encodeURIComponent ++ categoryQuery}
                text={<div style={ReactDOM.Style.make(~display="flex", ~alignItems="center", ())}>
                  <img
                    style={ReactDOM.Style.make(~width="12px", ~marginRight="4px", ())}
                    src={dogImage}
                  />
                  <HighlightTerms text=entityName terms=searchMatchingTerms />
                </div>}
              />
            } else {
              React.null
            }
          | Dogx(_) =>
            if isEntityNameMatchSearch || parentCategoryMatchedSearch {
              <Link
                key={entityName}
                style=Styles.dogxLink
                activeStyle=Styles.activeLink
                href={"/?dogx=" ++ entityName->Js.Global.encodeURIComponent ++ categoryQuery}
                text={<div style={ReactDOM.Style.make(~display="flex", ~alignItems="center", ())}>
                  <img
                    style={ReactDOM.Style.make(~width="12px", ~marginRight="4px", ())}
                    src={dogxImage}
                  />
                  <HighlightTerms text=entityName terms=searchMatchingTerms />
                </div>}
              />
            } else {
              React.null
            }
          | Category(demos) =>
            if (
              isEntityNameMatchSearch ||
              Demos.isNestedEntityMatchSearch(demos, searchString) ||
              parentCategoryMatchedSearch
            ) {
              let levelStr = Int.toString(nestingLevel)
              let categoryQueryKey = `category${levelStr}`
              let isCategoryInQuery = switch urlSearchParams->URLSearchParams.get(
                categoryQueryKey,
              ) {
              | Some(value) if value->Js.Global.decodeURIComponent == entityName => true
              | Some(_) | None => false
              }

              <PaddedBox key={entityName} padding=LeftRight>
                <Collapsible
                  title={<div style=Styles.categoryName>
                    <HighlightTerms text=entityName terms=searchMatchingTerms />
                  </div>}
                  initialValue={isCategoryInQuery}>
                  <PaddedBox padding=LeftRight>
                    {renderMenu(
                      ~parentCategoryMatchedSearch=isEntityNameMatchSearch ||
                      parentCategoryMatchedSearch,
                      ~nestingLevel=nestingLevel + 1,
                      ~categoryQuery=`&category${levelStr}=` ++
                      entityName->Js.Global.encodeURIComponent ++
                      categoryQuery,
                      demos,
                    )}
                  </PaddedBox>
                </Collapsible>
              </PaddedBox>
            } else {
              React.null
            }
          }
        })
        ->React.array

      <> {renderedDemos} </>
    }

    renderMenu(
      ~parentCategoryMatchedSearch=false,
      ~nestingLevel=0,
      ~categoryQuery="",
      (demos: Demos.t),
    )
  }

  @react.component
  let make = (
    ~logo: option<string>,
    ~intro: bool,
    ~sortDogs: option<((string, Entity.t), (string, Entity.t)) => int>,
    ~urlSearchParams: URLSearchParams.t,
    ~demos: Demos.t,
  ) => {
    let (filterValue, setFilterValue) = React.useState(() => None)
    let searchString = filterValue->Option.mapWithDefault("", Js.String2.toLowerCase)

    <Sidebar fullHeight=true>
      <PaddedBox gap=Md border=Bottom>
        {switch logo {
        | Some(source) =>
          <div style={ReactDOM.Style.make(~display="flex", ~justifyContent="center", ())}>
            <img
              style={ReactDOM.Style.make(
                ~maxHeight="70px",
                ~maxWidth="100%",
                ~marginBottom="10px",
                (),
              )}
              src={source}
            />
          </div>
        | None => React.null
        }}
        <div style={ReactDOM.Style.make(~display="flex", ~alignItems="center", ~gridGap="5px", ())}>
          <SearchInput
            value={filterValue->Option.getWithDefault("")}
            onChange={event => {
              let value = (event->ReactEvent.Form.target)["value"]
              setFilterValue(_ => value->Js.String2.trim == "" ? None : Some(value))
            }}
            onClear={() => setFilterValue(_ => None)}
          />
        </div>
      </PaddedBox>
      <PaddedBox gap=Xxs>
        {switch intro {
        | true =>
          <div style=Styles.introLink>
            <Link
              style=Styles.link
              activeStyle=Styles.activeLink
              href={"/"}
              text={<HighlightTerms
                text="Intro"
                terms={HighlightTerms.getMatchingTerms(~searchString, ~entityName="intro")}
              />}
            />
          </div>
        | false => React.null
        }}
        {renderMenu(~searchString, ~urlSearchParams, ~sortDogs, demos)}
      </PaddedBox>
    </Sidebar>
  }
}

module DemoUnitFrame = {
  let container = () =>
    ReactDOM.Style.make(
      ~flex="1",
      ~display="flex",
      ~justifyContent="center",
      ~alignItems="center",
      ~height="1px",
      ~overflowY="auto",
      (),
    )

  let useFullframeUrl: bool = %raw(`typeof USE_FULL_IFRAME_URL === "boolean" ? USE_FULL_IFRAME_URL : false`)

  @react.component
  let make = (~queryString: string) => {
    let iframePath = useFullframeUrl ? "/demo/index.html" : "/demo"
    <div name="DemoUnitFrame" style={container()}>
      <iframe
        src={`${iframePath}?iframe=true&${queryString}`}
        style={ReactDOM.Style.make(~height="100%", ~width="100%", ~border="none", ())}
      />
    </div>
  }
}

module App = {
  module Styles = {
    let app = ReactDOM.Style.make(
      ~display="flex",
      ~flexDirection="row",
      ~minHeight="100vh",
      ~alignItems="stretch",
      ~color=Color.darkGray,
      (),
    )
    let main = ReactDOM.Style.make(~flexGrow="1", ~display="flex", ~flexDirection="column", ())
    let intro = ReactDOM.Style.make(~flexGrow="1", ~display="flex", ~justifyContent="center", ())
    let emptyText = ReactDOM.Style.make(
      ~fontSize=FontSize.lg,
      ~color=Color.black40a,
      ~display="flex",
      ~alignItems="center",
      (),
    )
    let right = ReactDOM.Style.make(~display="flex", ~flexDirection="column", ~width="100%", ())
    let demo = ReactDOM.Style.make(
      ~display="flex",
      ~flex="1",
      ~flexDirection="row",
      ~alignItems="stretch",
      (),
    )
    let demoContents = ReactDOM.Style.make(~display="flex", ~flex="1", ~flexDirection="column", ())
  }

  type commonRoute =
    | Demo(string)
    | Dogx(string)
    | Home

  type route =
    | UnitDog(URLSearchParams.t, string)
    | UnitDogx(URLSearchParams.t, string)
    | CommonRoute(commonRoute)

  @react.component
  let make = (
    ~logo: option<string>,
    ~demos: Demos.t,
    ~sortDogs: option<((string, Entity.t), (string, Entity.t)) => int>,
    ~intro: option<React.element>,
    ~applyDecorators: (React.element, context) => React.element,
  ) => {
    let url = RescriptReactRouter.useUrl()
    let urlSearchParams = url.search->URLSearchParams.make
    let route = switch (
      urlSearchParams->URLSearchParams.get("iframe"),
      urlSearchParams->URLSearchParams.get("dog"),
      urlSearchParams->URLSearchParams.get("dogx"),
    ) {
    | (Some("true"), Some(demoName), _) => UnitDog(urlSearchParams, demoName)
    | (Some("true"), None, Some(dogxName)) => UnitDogx(urlSearchParams, dogxName)
    | (_, value, dogx) =>
      switch (value, dogx) {
      | (Some(_), _) => CommonRoute(Demo(url.search))
      | (_, Some(_)) => CommonRoute(Dogx(url.search))
      | _ => CommonRoute(Home)
      }
    }
    let _sortedDemos =
      demos->Js.Dict.entries->Belt.SortArray.stableSortBy(((a, _), (b, _)) => String.compare(a, b))

    // Force rerender after switching demo to avoid stale iframe and sidebar children
    let (iframeKey, setIframeKey) = React.useState(() => Js.Date.now()->Float.toString)
    React.useEffect1(() => {
      setIframeKey(_ => Js.Date.now()->Float.toString)
      None
    }, [url])

    <div name="App" style=Styles.app>
      <ResponsiveContext responsiveMode=ResponsiveContext.Desktop>
        {switch route {
        | UnitDog(urlSearchParams, demoName) => {
            let demoUnit = Demos.findDemo(urlSearchParams, demoName, demos)

            <div style=Styles.main>
              <TopPanel />
              {demoUnit
              ->Option.map(demoUnit =>
                <DogUnit
                  demoUnit={controls => applyDecorators(demoUnit(controls), {controls: controls})}
                />
              )
              ->Option.getWithDefault("Demo not found"->React.string)}
            </div>
          }
        | UnitDogx(urlSearchParams, demoName) => {
            let demoUnit = Demos.findDemo(urlSearchParams, demoName, demos)

            <div style=Styles.main>
              {demoUnit
              ->Option.map(demoUnit =>
                <DogUnit
                  demoUnit={controls => applyDecorators(demoUnit(controls), {controls: controls})}
                />
              )
              ->Option.getWithDefault("Demo not found"->React.string)}
            </div>
          }
        | CommonRoute(commonRoute) =>
          <>
            <DemoListSidebar
              logo
              demos
              sortDogs
              intro={switch intro {
              | Some(_) => true
              | None => false
              }}
              urlSearchParams
            />
            {switch commonRoute {
            | Demo(queryString) =>
              <>
                <div name="Content" style=Styles.right>
                  <div name="Demo" style=Styles.demo>
                    <div style=Styles.demoContents>
                      <DemoUnitFrame key={"DemoUnitFrame" ++ iframeKey} queryString />
                    </div>
                  </div>
                </div>
              </>
            | Dogx(queryString) =>
              <>
                <div name="Content" style=Styles.right>
                  <div name="Demo" style=Styles.demo>
                    <div style=Styles.demoContents>
                      <DemoUnitFrame key={"DemoUnitFrame" ++ iframeKey} queryString />
                    </div>
                  </div>
                </div>
              </>
            | Home =>
              <>
                <div style=Styles.intro>
                  {switch intro {
                  | Some(intro) =>
                    <div style={ReactDOM.Style.make(~padding="10px", ~maxWidth="1000px", ())}>
                      {intro}
                    </div>
                  | None =>
                    <div style=Styles.emptyText> {"Pick a demo on the sidebar"->React.string} </div>
                  }}
                </div>
              </>
            }}
          </>
        }}
      </ResponsiveContext>
    </div>
  }
}
