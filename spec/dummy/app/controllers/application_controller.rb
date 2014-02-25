class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Ensure application doesn't allow browser to store page in
  # internal browser cache (and history)
  def set_secure_environment
    # As suggested in :
    # * https://www.owasp.org/index.php/OWASP_Application_Security_FAQ
    # * http://www.mnot.net/cache_docs/#CACHE-CONTROL
    # no-store is vital for chrome to prevent caching of page values
    # However, you must then use full POST-REDIRECT-GET for both success/errors
    # and skip rails usual POST -> render errors pattern.
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"]        = "no-cache"
    response.headers["Expires"]       = "-1"
  end
end
