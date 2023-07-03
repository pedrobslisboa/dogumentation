@module("./favicon.ico")
external favicon: string = "default"

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
                text={<div
                  style={ReactDOM.Style.make(~display="flex", ~alignItems="center", ())}
                  src={favicon}>
                  <img
                    style={ReactDOM.Style.make(~width="12px", ~marginRight="4px", ())} src={favicon}
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

module DemoUnitSidebar = {
  module Styles = {
    let label = ReactDOM.Style.make(
      ~display="block",
      ~backgroundColor=Color.white,
      ~borderRadius=BorderRadius.default,
      ~boxShadow="0 5px 10px rgba(0, 0, 0, 0.07)",
      (),
    )

    let labelText = ReactDOM.Style.make(~fontSize=FontSize.md, ~textAlign="center", ())

    let textInput = ReactDOM.Style.make(
      ~fontSize=FontSize.md,
      ~width="100%",
      ~boxSizing="border-box",
      ~backgroundColor=Color.lightGray,
      ~boxShadow="inset 0 0 0 1px rgba(0, 0, 0, 0.1)",
      ~border="none",
      ~padding=Gap.md,
      ~borderRadius=BorderRadius.default,
      (),
    )

    let select =
      ReactDOM.Style.make(
        ~fontSize=FontSize.md,
        ~width="100%",
        ~boxSizing="border-box",
        ~backgroundColor=Color.lightGray,
        ~boxShadow="inset 0 0 0 1px rgba(0, 0, 0, 0.1)",
        ~border="none",
        ~padding=Gap.md,
        ~borderRadius=BorderRadius.default,
        ~appearance="none",
        ~paddingRight="30px",
        ~backgroundImage=`url("data:image/svg+xml,%3Csvg width='36' height='36' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath stroke='%2342484E' stroke-width='2' d='M12.246 14.847l5.826 5.826 5.827-5.826' fill='none' fill-rule='evenodd' stroke-linecap='round' stroke-linejoin='round'/%3E%3C/svg%3E")`,
        ~backgroundPosition="center right",
        ~backgroundSize="contain",
        ~backgroundRepeat="no-repeat",
        (),
      )->ReactDOM.Style.unsafeAddProp("WebkitAppearance", "none")

    let checkbox = ReactDOM.Style.make(
      ~fontSize=FontSize.md,
      ~margin="0 auto",
      ~display="block",
      (),
    )
  }

  module PropBox = {
    @react.component
    let make = (~propName: string, ~children) => {
      <label style=Styles.label>
        <PaddedBox>
          <Stack>
            <div style=Styles.labelText> {propName->React.string} </div>
            children
          </Stack>
        </PaddedBox>
      </label>
    }
  }

  @react.component
  let make = (
    ~strings: Map.String.t<(Controls.stringConfig, string, option<array<(string, string)>>)>,
    ~ints: Map.String.t<(Controls.numberConfig<int>, int)>,
    ~floats: Map.String.t<(Controls.numberConfig<float>, float)>,
    ~bools: Map.String.t<(Controls.boolConfig, bool)>,
    ~onStringChange,
    ~onIntChange,
    ~onFloatChange,
    ~onBoolChange,
  ) =>
    <PaddedBox gap=Md>
      <Stack>
        {strings
        ->Map.String.toArray
        ->Array.map(((propName, (_config, value, options))) =>
          <PropBox key=propName propName>
            {switch options {
            | None =>
              <input
                type_="text"
                value
                style=Styles.textInput
                onChange={event =>
                  onStringChange(propName, (event->ReactEvent.Form.target)["value"])}
              />
            | Some(options) =>
              <select
                style=Styles.select
                value={value}
                onChange={event => {
                  let value = (event->ReactEvent.Form.target)["value"]
                  onStringChange(propName, value)
                }}>
                {options
                ->Array.map(((key, optionValue)) => {
                  <option key value={optionValue}> {key->React.string} </option>
                })
                ->React.array}
              </select>
            }}
          </PropBox>
        )
        ->React.array}
        {ints
        ->Map.String.toArray
        ->Array.map(((propName, ({min, max}, value))) =>
          <PropBox key=propName propName>
            <input
              type_="number"
              min={Belt.Int.toString(min)}
              max={Belt.Int.toString(max)}
              value={Belt.Int.toString(value)}
              style=Styles.textInput
              onChange={event =>
                onIntChange(propName, (event->ReactEvent.Form.target)["value"]->int_of_string)}
            />
          </PropBox>
        )
        ->React.array}
        {floats
        ->Map.String.toArray
        ->Array.map(((propName, ({min, max}, value))) =>
          <PropBox key=propName propName>
            <input
              type_="number"
              min={`${min->Belt.Float.toString}`}
              max={`${max->Belt.Float.toString}`}
              value={`${value->Belt.Float.toString}`}
              style=Styles.textInput
              onChange={event =>
                onFloatChange(propName, (event->ReactEvent.Form.target)["value"]->float_of_string)}
            />
          </PropBox>
        )
        ->React.array}
        {bools
        ->Map.String.toArray
        ->Array.map(((propName, (_config, checked))) =>
          <PropBox key=propName propName>
            <input
              type_="checkbox"
              checked
              style=Styles.checkbox
              onChange={event => onBoolChange(propName, (event->ReactEvent.Form.target)["checked"])}
            />
          </PropBox>
        )
        ->React.array}
      </Stack>
    </PaddedBox>
}

module DemoUnit = {
  type state = {
    strings: Map.String.t<(Controls.stringConfig, string, option<array<(string, string)>>)>,
    ints: Map.String.t<(Controls.numberConfig<int>, int)>,
    floats: Map.String.t<(Controls.numberConfig<float>, float)>,
    bools: Map.String.t<(Controls.boolConfig, bool)>,
  }

  type action =
    | SetString(string, string)
    | SetInt(string, int)
    | SetFloat(string, float)
    | SetBool(string, bool)

  module Styles = {
    let container = ReactDOM.Style.make(
      ~flexGrow="1",
      ~display="flex",
      ~alignItems="stretch",
      ~flexDirection="row",
      ~padding="20px",
      (),
    )
    let contents =
      ReactDOM.Style.make(~flexGrow="1", ~overflowY="auto", ())->ReactDOM.Style.unsafeAddProp(
        "WebkitOverflowScrolling",
        "touch",
      )
  }

  let getRightSidebarElement = (): option<Dom.element> =>
    Window.window["parent"]["document"]["getElementById"](. rightSidebarId)->Js.Nullable.toOption

  @react.component
  let make = (~demoUnit: Controls.demoUnitProps => React.element) => {
    let (parentWindowRightSidebarElem, setParentWindowRightSidebarElem) = React.useState(() => None)

    React.useEffect0(() => {
      switch getRightSidebarElement() {
      | Some(elem) => setParentWindowRightSidebarElem(_ => Some(elem))
      | None => ()
      }
      None
    })

    React.useEffect0(() => {
      Window.addMessageListener(event => {
        if Window.window["parent"] === event["source"] {
          let message: string = event["data"]
          switch message->Window.Message.fromStringOpt {
          | Some(RightSidebarDisplayed) =>
            switch getRightSidebarElement() {
            | Some(elem) => setParentWindowRightSidebarElem(_ => Some(elem))
            | None => ()
            }
          | None => Js.Console.error("Unexpected message received")
          }
        }
      })
      None
    })

    let (state, dispatch) = React.useReducer(
      (state, action) =>
        switch action {
        | SetString(name, newValue) => {
            ...state,
            strings: state.strings->Map.String.update(name, value =>
              value->Option.map(((config, _value, options)) => (config, newValue, options))
            ),
          }
        | SetInt(name, newValue) => {
            ...state,
            ints: state.ints->Map.String.update(name, value =>
              value->Option.map(((config, _value)) => (config, newValue))
            ),
          }
        | SetFloat(name, newValue) => {
            ...state,
            floats: state.floats->Map.String.update(name, value =>
              value->Option.map(((config, _value)) => (config, newValue))
            ),
          }
        | SetBool(name, newValue) => {
            ...state,
            bools: state.bools->Map.String.update(name, value =>
              value->Option.map(((config, _value)) => (config, newValue))
            ),
          }
        },
      {
        let strings = ref(Map.String.empty)
        let ints = ref(Map.String.empty)
        let floats = ref(Map.String.empty)
        let bools = ref(Map.String.empty)
        let props: Controls.demoUnitProps = {
          string: (name, ~options=?, config) => {
            strings := strings.contents->Map.String.set(name, (config, config, options))
            config
          },
          int: (name, config) => {
            ints := ints.contents->Map.String.set(name, (config, config.initial))
            config.initial
          },
          float: (name, config) => {
            floats := floats.contents->Map.String.set(name, (config, config.initial))
            config.initial
          },
          bool: (name, config) => {
            bools := bools.contents->Map.String.set(name, (config, config))
            config
          },
        }
        let _ = demoUnit(props)
        {
          strings: strings.contents,
          ints: ints.contents,
          floats: floats.contents,
          bools: bools.contents,
        }
      },
    )
    let props: Controls.demoUnitProps = {
      string: (name, ~options as _=?, _config) => {
        let (_, value, _) = state.strings->Map.String.getExn(name)
        value
      },
      int: (name, _config) => {
        let (_, value) = state.ints->Map.String.getExn(name)
        value
      },
      float: (name, _config) => {
        let (_, value) = state.floats->Map.String.getExn(name)
        value
      },
      bool: (name, _config) => {
        let (_, value) = state.bools->Map.String.getExn(name)
        value
      },
    }

    <div name="DemoUnit" style=Styles.container>
      <div style=Styles.contents> {demoUnit(props)} </div>
      {switch parentWindowRightSidebarElem {
      | None => React.null
      | Some(element) =>
        ReactDOM.createPortal(
          <DemoUnitSidebar
            strings=state.strings
            ints=state.ints
            floats=state.floats
            bools=state.bools
            onStringChange={(name, value) => dispatch(SetString(name, value))}
            onIntChange={(name, value) => dispatch(SetInt(name, value))}
            onFloatChange={(name, value) => dispatch(SetFloat(name, value))}
            onBoolChange={(name, value) => dispatch(SetBool(name, value))}
          />,
          element,
        )
      }}
    </div>
  }
}

module DemoUnitFrame = {
  let container = responsiveMode =>
    ReactDOM.Style.make(
      ~flex="1",
      ~display="flex",
      ~justifyContent="center",
      ~alignItems="center",
      ~backgroundColor={
        switch responsiveMode {
        | TopPanel.Mobile => Color.midGray
        | TopPanel.Desktop => Color.white
        }
      },
      ~height="1px",
      ~overflowY="auto",
      (),
    )

  let useFullframeUrl: bool = %raw(`typeof USE_FULL_IFRAME_URL === "boolean" ? USE_FULL_IFRAME_URL : false`)

  @react.component
  let make = (~queryString: string, ~responsiveMode, ~onLoad: Js.t<'a> => unit) => {
    let iframePath = useFullframeUrl ? "/demo/index.html" : "/demo"
    <div name="DemoUnitFrame" style={container(responsiveMode)}>
      <iframe
        onLoad={event => {
          let iframe = event->ReactEvent.Synthetic.target
          let window = iframe["contentWindow"]
          onLoad(window)
        }}
        src={`${iframePath}?iframe=true&${queryString}`}
        style={ReactDOM.Style.make(
          ~height={
            switch responsiveMode {
            | Mobile => "667px"
            | Desktop => "100%"
            }
          },
          ~width={
            switch responsiveMode {
            | Mobile => "375px"
            | Desktop => "100%"
            }
          },
          ~border="none",
          (),
        )}
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
    | Home

  type route =
    | Unit(URLSearchParams.t, string)
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
    ) {
    | (Some("true"), Some(demoName)) => Unit(urlSearchParams, demoName)
    | (_, value) =>
      switch value {
      | Some(_) => CommonRoute(Demo(url.search))
      | None => CommonRoute(Home)
      }
    }
    let _sortedDemos =
      demos->Js.Dict.entries->Belt.SortArray.stableSortBy(((a, _), (b, _)) => String.compare(a, b))

    let (loadedIframeWindow: option<Js.t<'a>>, setLoadedIframeWindow) = React.useState(() => None)

    // Force rerender after switching demo to avoid stale iframe and sidebar children
    let (iframeKey, setIframeKey) = React.useState(() => Js.Date.now()->Float.toString)
    React.useEffect1(() => {
      setIframeKey(_ => Js.Date.now()->Float.toString)
      None
    }, [url])

    let (showRightSidebar, toggleShowRightSidebar) = React.useState(() => {
      LocalStorage.localStorage->LocalStorage.getItem("sidebar")->Option.isSome
    })

    let (responsiveMode, onSetResponsiveMode) = React.useState(() => TopPanel.Desktop)

    React.useEffect1(() => {
      if showRightSidebar {
        LocalStorage.localStorage->LocalStorage.setItem("sidebar", "1")
      } else {
        LocalStorage.localStorage->LocalStorage.removeItem("sidebar")
      }
      None
    }, [showRightSidebar])

    <div name="App" style=Styles.app>
      {switch route {
      | Unit(urlSearchParams, demoName) => {
          let demoUnit = Demos.findDemo(urlSearchParams, demoName, demos)

          <div style=Styles.main>
            {demoUnit
            ->Option.map(demoUnit =>
              <DemoUnit
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
                <TopPanel
                  isSidebarHidden={!showRightSidebar}
                  responsiveMode
                  onRightSidebarToggle={() => {
                    toggleShowRightSidebar(_ => !showRightSidebar)
                    switch loadedIframeWindow {
                    | Some(window) if !showRightSidebar =>
                      Window.postMessage(window, RightSidebarDisplayed)
                    | None
                    | _ => ()
                    }
                  }}
                  onSetResponsiveMode
                />
                <div name="Demo" style=Styles.demo>
                  <div style=Styles.demoContents>
                    <DemoUnitFrame
                      key={"DemoUnitFrame" ++ iframeKey}
                      queryString
                      responsiveMode
                      onLoad={iframeWindow => setLoadedIframeWindow(_ => Some(iframeWindow))}
                    />
                  </div>
                  {showRightSidebar
                    ? <Sidebar key={"Sidebar" ++ iframeKey} innerContainerId=rightSidebarId />
                    : React.null}
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
    </div>
  }
}
