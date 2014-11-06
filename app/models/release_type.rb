# This probably shouldn't be used directly, it's the base class for
# releases.  At the moment the only release type is EstimatedRelease,
# but when we have user logins we can have Confirmed/Denied or
# something like that
class ReleaseType < ActiveRecord::Base

end
