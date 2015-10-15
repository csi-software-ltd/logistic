class Dynconfig {
  static mapping = {
    version false
  }

  String name
  String value
  String comment

	def afterUpdate(){
		Confighistory.withNewSession{
			new Confighistory (name:name,value:value).save(flush:true)
		}
	}

	Dynconfig updateValue(_value){
		value = _value
		this
	}

}