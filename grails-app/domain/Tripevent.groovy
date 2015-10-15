class Tripevent {

  static mapping = {
    version false
  }
  static constraints = {
  }

  Long id
  Integer type_id
  Long trip_id
	Date eventdate = new Date()

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	def beforeInsert() {
		if (Tripeventtype.get(type_id)?.levelcur) Trip.withSession{ sess -> sess.get(Trip.class,trip_id)?.csiSetUnreadEvent(1).save() } //die fucking hibernate, die, die, die!! Don`t eat my brain!
    if (Tripeventtype.get(type_id)?.levelship) Trip.withSession{ sess -> sess.get(Trip.class,trip_id)?.csiSetUnreadEvent(2).save() }
		if (Tripeventtype.get(type_id)?.leveladm) Trip.withSession{ sess -> sess.get(Trip.class,trip_id)?.csiSetUnreadEvent(3).save() }
	}

}