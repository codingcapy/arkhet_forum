import api
import model
import rsvp

pub type Msg {
  OnRouteChange(model.Route)
  Navigate(String)
  UserChangedSignupUsername(String)
  UserChangedSignupEmail(String)
  UserChangedSignupPassword(String)
  UserSubmittedSignup
  ApiCreatedUser(Result(api.User, rsvp.Error))
  UserChangedLoginEmail(String)
  UserChangedLoginPassword(String)
  UserSubmittedLogin
  ApiLoggedInUser(Result(api.AuthResult, rsvp.Error))
  Logout
  None
}
