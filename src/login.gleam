import gleam/option
import lustre/attribute.{class}
import lustre/element/html
import lustre/event
import message
import model

pub fn view(model: model.Model) {
  html.div([attribute.class("pt-[50px] mx-auto w-[300px] p-2")], [
    html.div(
      [attribute.class("text-center text-[#9253E4] font-bold mb-10 text-xl")],
      [
        html.text("LOGIN"),
      ],
    ),
    case model.login_ui.error {
      option.Some(msg) ->
        html.div([class("mb-4 text-sm text-red-400 text-center")], [
          html.text(msg),
        ])

      option.None -> html.text("")
    },
    html.form(
      [
        class("flex flex-col"),
        event.on_submit(fn(_) { message.UserSubmittedLogin }),
      ],
      [
        html.input([
          class("border my-1 p-2"),
          attribute.placeholder("Email"),
          attribute.type_("email"),
          attribute.required(True),
          event.on_change(message.UserChangedLoginEmail),
        ]),
        html.input([
          class("border my-1 p-2"),
          attribute.placeholder("Password"),
          attribute.type_("password"),
          attribute.required(True),
          event.on_change(message.UserChangedLoginPassword),
        ]),
        html.button([class("bg-[#9253E4] rounded-full px-5 py-3 my-5")], [
          html.text("LOGIN"),
        ]),
        html.div([class("flex")], [
          html.div([class("mr-2")], [
            html.text("Don't have an account?"),
          ]),
          html.a(
            [
              attribute.href("/signup"),
              class(
                "hover:text-[#9253E4] transition-all ease-in-out duration-300",
              ),
            ],
            [
              html.text("Signup"),
            ],
          ),
        ]),
      ],
    ),
  ])
}
