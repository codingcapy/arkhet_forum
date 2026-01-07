import api
import gleam/io
import gleam/option
import gleam/string
import gleam/uri
import login
import lustre
import lustre/attribute.{class}
import lustre/effect
import lustre/element/html
import lustre/event
import message
import model.{type Model, type Route, Home, Login, Model, Signup}
import modem
import signup

pub fn main() -> Nil {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

fn init(_) {
  let model =
    model.Model(
      route: model.initial_route(),
      signup_ui: model.initial_signup_ui(),
      login_ui: model.initial_login_ui(),
      auth_token: option.None,
      current_user: option.None,
    )
  let fx = effect.batch([modem.init(on_url_change)])
  #(model, fx)
}

fn update(
  model: Model,
  msg: message.Msg,
) -> #(Model, effect.Effect(message.Msg)) {
  case echo msg {
    message.OnRouteChange(route) -> #(
      model.Model(..model, route: route),
      effect.none(),
    )
    message.Navigate(path) -> #(
      model,
      modem.push(path, option.None, option.None),
    )
    message.UserChangedSignupUsername(username) -> {
      let signup_ui = model.SignupUi(..model.signup_ui, username: username)
      #(Model(..model, signup_ui:), effect.none())
    }
    message.UserChangedSignupEmail(email) -> {
      let signup_ui = model.SignupUi(..model.signup_ui, email: email)
      #(Model(..model, signup_ui:), effect.none())
    }
    message.UserChangedSignupPassword(password) -> {
      let signup_ui = model.SignupUi(..model.signup_ui, password: password)
      #(Model(..model, signup_ui:), effect.none())
    }
    message.UserSubmittedSignup -> {
      let username = echo model.signup_ui.username |> string.trim()
      let email = echo model.signup_ui.email |> string.trim()
      let password = echo model.signup_ui.password |> string.trim()
      let fx =
        api.post_signup(message.ApiCreatedUser, username:, email:, password:)
      #(model, fx)
    }
    message.ApiCreatedUser(Ok(_)) -> {
      let email = echo model.signup_ui.email |> string.trim()
      let password = echo model.signup_ui.password |> string.trim()
      #(
        Model(..model),
        effect.batch([
          api.post_login(message.ApiLoggedInUser, email:, password:),
        ]),
      )
    }
    message.ApiCreatedUser(Error(error)) -> {
      echo error
      #(Model(..model), effect.none())
    }
    message.UserChangedLoginEmail(email) -> {
      let login_ui = model.LoginUi(..model.login_ui, email: email)
      #(Model(..model, login_ui:), effect.none())
    }
    message.UserChangedLoginPassword(password) -> {
      let login_ui = model.LoginUi(..model.login_ui, password: password)
      #(Model(..model, login_ui:), effect.none())
    }
    message.UserSubmittedLogin -> {
      let email = echo model.login_ui.email |> string.trim()
      let password = echo model.login_ui.password |> string.trim()
      let fx = api.post_login(message.ApiLoggedInUser, email:, password:)
      #(model, fx)
    }
    message.ApiLoggedInUser(Ok(auth_result)) -> {
      io.println("Login succeeded")
      #(
        Model(
          ..model,
          login_ui: model.initial_login_ui(),
          auth_token: option.Some(auth_result.token),
          current_user: option.Some(auth_result.user),
        ),
        modem.push("/", option.None, option.None),
      )
    }
    message.ApiLoggedInUser(Error(error)) -> {
      io.println("Login failed")
      #(model, effect.none())
    }
    message.Logout -> {
      #(
        Model(..model, auth_token: option.None, current_user: option.None),
        effect.none(),
      )
    }
    message.None -> #(model, effect.none())
  }
}

fn view(model: Model) {
  html.div(
    [attribute.class("flex flex-col min-h-screen bg-[#222222] text-white")],
    [
      view_header(model),
      case model.route {
        Home ->
          html.div([attribute.class("pt-[150px] max-w-[1000px] mx-auto")], [
            html.div([attribute.class("text-2xl font-bold mb-5")], [
              html.text("Categories"),
            ]),
            html.div(
              [
                class(
                  "p-5 my-3 lg:w-[700px] bg-[#303030] border cursor-pointer hover:bg-[#444444]",
                ),
              ],
              [
                html.div([class("text-xl font-bold")], [
                  html.text("Bug Reports"),
                ]),
                html.div([class("text-[#bbbbbb]")], [
                  html.text(
                    "Find a bug? Help us squash it by reporting it here!",
                  ),
                ]),
              ],
            ),
            html.div(
              [
                class(
                  "p-5 my-3 lg:w-[700px] bg-[#303030] border cursor-pointer hover:bg-[#444444]",
                ),
              ],
              [
                html.div([class("text-xl font-bold")], [
                  html.text("Technical Support"),
                ]),
                html.div([class("text-[#bbbbbb]")], [
                  html.text(
                    "For account issues such as signing up/logging in, billing and payments",
                  ),
                ]),
              ],
            ),
            html.div(
              [
                class(
                  "p-5 my-3 lg:w-[700px] bg-[#303030] border cursor-pointer hover:bg-[#444444]",
                ),
              ],
              [
                html.div([class("text-xl font-bold")], [
                  html.text("General Discussion"),
                ]),
                html.div([class("text-[#bbbbbb]")], [
                  html.text("Discussion about Arkhet"),
                ]),
              ],
            ),
          ])
        Signup -> signup.view(model)
        Login -> login.view()
      },
    ],
  )
}

fn view_header(model: Model) {
  html.header(
    [
      attribute.class(
        "fixed top-0 left-0 w-screen flex justify-between p-2 bg-[#222222]",
      ),
    ],
    [
      html.a(
        [
          event.on_click(message.Navigate("/")),
          attribute.class(
            "pt-1 tracking-[0.25rem] text-xl hover:text-[#9253E4] transition-all ease-in-out duration-300 cursor-pointer",
          ),
        ],
        [
          html.div([class("flex")], [
            html.div([class("mr-2")], [
              html.img([attribute.src("/logo.png"), class("w-[30px]")]),
            ]),
            html.text("ARKHET"),
          ]),
        ],
      ),
      case model.current_user {
        option.None ->
          html.div([class("flex")], [
            html.a(
              [
                event.on_click(message.Navigate("/login")),
                class("px-5 py-2 hover:text-[#9253E4] cursor-pointer"),
              ],
              [html.text("Login")],
            ),
            html.a(
              [
                event.on_click(message.Navigate("/signup")),
                class("bg-[#9253E4] rounded-full px-5 py-2 cursor-pointer"),
              ],
              [html.text("Signup")],
            ),
          ])
        option.Some(user) ->
          html.div([class("flex items-center px-5 py-2")], [
            html.text(echo user.username),
            html.a(
              [
                event.on_click(message.Logout),
                class("ml-4 text-sm hover:text-red-400 cursor-pointer"),
              ],
              [html.text("Logout")],
            ),
          ])
      },
    ],
  )
}

fn on_url_change(uri: uri.Uri) -> message.Msg {
  uri.path
  |> uri.path_segments
  |> model.route_from_path
  |> message.OnRouteChange
}
