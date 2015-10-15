class Slot {

  static mapping = {
    version false
    sort "start"
  }

  static constraints = {
  }

  Integer id
  Integer terminal_id
  String name
  String start = ''
  String end = ''
  Integer modstatus = 1

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def afterDelete(){
    Slot.withNewSession{
      def tmp = this
      if(!(Slot.findAll{ terminal_id == tmp.terminal_id && modstatus == 1 && id != tmp.id }?true:false)) Terminal.get(terminal_id).csiSetIsSlot(0).save(flush:true)
    }
  }

  def afterInsert(){
    Slot.withNewSession{
      if(Slot.findByTerminal_idAndModstatus(terminal_id,1)) Terminal.get(terminal_id).csiSetIsSlot(1).save(flush:true)
    }
  }

  def afterUpdate(){
    Slot.withNewSession{
      def tmp = this
      if((Slot.findAll{ terminal_id == tmp.terminal_id && modstatus == 1 && id != tmp.id }?true:false)||modstatus==1) Terminal.get(terminal_id).csiSetIsSlot(1).save(flush:true)
      else Terminal.get(terminal_id).csiSetIsSlot(0).save(flush:true)
    }
  }

  Slot setData(lsRequest){
    name = lsRequest.slot_name?:name
    start = lsRequest.slot_start?:''
    end = lsRequest.slot_end?:''
    terminal_id = lsRequest.terminal_id?:terminal_id
    modstatus = (lsRequest.slot_modstatus&&lsRequest.slot_start&&lsRequest.slot_end)?1:0
    this
  }

  def getTimeStart(){
    return start.split(':')[0].isInteger()?start.split(':')[0].toInteger():0
  }
  def getTimeEnd(){
    return end.split(':')[0].isInteger()?end.split(':')[0].toInteger():0
  }

}