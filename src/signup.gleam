import lustre/attribute.{class, value}
import lustre/element/html
import lustre/event
import message
import model.{type Model}

pub fn view(model: Model) {
  html.div([class("pt-[50px] mx-auto w-[300px] p-2")], [
    html.div([class("text-center text-[#9253E4] font-bold mb-10 text-xl")], [
      html.text("SIGNUP"),
    ]),
    html.form(
      [
        class("flex flex-col"),
        event.on_submit(fn(_) { message.UserSubmittedSignup }),
      ],
      [
        html.input([
          class("border my-1 p-2"),
          attribute.placeholder("Username"),
          attribute.required(True),
          attribute.name("username"),
          attribute.id("username"),
          attribute.type_("text"),
          value(model.signup_ui.username),
          // <-- bind input to model
          event.on_change(message.UserChangedSignupUsername),
        ]),
        html.input([
          class("border my-1 p-2"),
          attribute.placeholder("Email"),
          attribute.type_("email"),
          attribute.required(True),
          attribute.name("email"),
          attribute.id("email"),
          value(model.signup_ui.email),
          event.on_change(message.UserChangedSignupEmail),
        ]),
        html.input([
          class("border my-1 p-2"),
          attribute.placeholder("Password"),
          attribute.type_("password"),
          attribute.required(True),
          attribute.name("password"),
          attribute.id("password"),
          value(model.signup_ui.password),
          event.on_change(message.UserChangedSignupPassword),
        ]),
        html.button([class("bg-[#9253E4] rounded-full px-5 py-3 my-5")], [
          html.text("SIGNUP"),
        ]),
        html.div([class("flex")], [
          html.div([class("mr-2")], [
            html.text("Already have an account?"),
          ]),
          html.a(
            [
              attribute.href("/login"),
              class(
                "hover:text-[#9253E4] transition-all ease-in-out duration-300",
              ),
            ],
            [html.text("Login")],
          ),
        ]),
      ],
    ),
  ])
}
