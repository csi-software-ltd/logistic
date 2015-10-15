import org.codehaus.groovy.grails.commons.ConfigurationHolder
import java.util.regex.Matcher
import java.util.regex.Pattern
import java.security.MessageDigest
import javax.crypto.Mac
import javax.crypto.spec.SecretKeySpec

class Tools  {   
  static prepareSearchString(sRequest){
    //из пользовательской ключевой фразы надо выкидывать символы:
    //    * ' " , ; %  с заменой их на  заменяя их на пробел
    //   - с заменой на пустой символ
    if(sRequest==null)
      return ''
    sRequest=sRequest.replace("'", ' ').replace('"',' ').replace(',',' ').replace(';',' ')
    sRequest=sRequest.replace('.',' ').replace('%',' ').replace('_',' ').replace('?',' ').replace('!',' ').replace('/',' ')
    return sRequest.replaceAll(/\s+/, " ").trim()
  }
  ///////////////////////////////////////////////////////////////////////////////
  static prepareEmailString(sEmail){
    // remove -,.,@
    if(sEmail==null)
      return ''
    return sEmail.replace("@", '').replace('-','').replace('.','')
  }
  ///////////////////////////////////////////////////////////////////////////////
  static checkEmailString(sEmail){
    return sEmail ==~ /^[_A-Za-z0-9](([_\.\-]?[a-zA-Z0-9]+)*)[_]*@([A-Za-z0-9]+)(([\.\-]?[a-zA-Z0-9]+)*)\.([A-Za-z]{2,})$/
  }
  /////////////////////////////////////////////////////////////////////////////
  static generateMD5(sText) {
    MessageDigest digest = java.security.MessageDigest.getInstance("MD5");
    digest.update(sText.getBytes());
    def mdRes=digest.digest()
    def sOut=''
    for (i in mdRes) 
      sOut+=Integer.toHexString(0xFF & i)
    return sOut;  
  }
  /////////////////////////////////////////////////////////////////////////////
  static hidePsw(sPsw) {
    return generateMD5('_yellcat'+sPsw+'yellcat-')
	/*def psw='_yellcat'+sPsw+'yellcat-'
	return psw.encodeAsMD5()*/
  }
  /////////////////////////////////////////////////////////////////////////////
  static getIntVal(sValue,iDefault=0){
    if(sValue==null)
      return iDefault
    try{
      iDefault=sValue.toInteger()
    }catch(Exception e){
      //do nothing
    }
    return iDefault
  }
  /////////////////////////////////////////////////////////////////////////////
  static Float getFloatVal(sValue,fDefault=0f){
    if(sValue==null)
      return fDefault
    try{
      fDefault=sValue.toFloat()
    }catch(Exception e){
      //do nothing
    }
    return fDefault
  }
  ///////////////////////////////////////////////////////////////////////////
  static String arrayToString(sValue,separator) {
    if(((sValue!=null)?sValue:[]).size()==0)
      return ''
    StringBuffer result = new StringBuffer();
    if (sValue.size() > 0) {
      result.append(sValue[0]);
      for (int i=1; i<sValue.size(); i++) {
        result.append(separator);
        result.append(sValue[i]);
      }
    }
    return result.toString();
  }
  ///////////////////////////////////////////////////////////////////////////
  static String escape(sValue){
    return sValue.replace("'","\\'").replace('"','\\"')
  }
  static fixHtml(sText,sFrom){
    if(!(sText?:'').size())
	  return ''
    def start=false
	def lsTags=[]
	switch(sFrom){
	  case 'admin': start=true;
        lsTags=['u','i','em','b','ol','ul','li','s','sub','sup','address','pre','p',
        'h1','h2','h3','h4','h5','h6','strong']
		break		
	  case 'personal':	
        if(Tools.getIntVal(ConfigurationHolder.config.editor.fixHtml)) start=true
        lsTags=['u','i','em','b','ol','ul','li','s','sub','sup','address','pre','p',
        'h1','h2','h3','h4','h5','h6','strong']
		break
	}	
	sText=sText.replace("\r",' ').replace("\n",' ').replace("'",'"')
	if(start){      
      sText=sText.replace("[YELLclose]",'').replace("[YELLspan]",'')
      sText=sText.replace('<br />','[YELLbr]')
      sText=sText.replace('<br>','[YELLbr]')
      sText=sText.replace('</span>','[/YELLspan]')
    
      sText=sText.replaceAll( /(<span )(style="[^\">]*?;")(>)/,'[YELLspan] $2[YELLclose]')
    
      for(sTag in lsTags) //TODO? change pre into p?
        sText=sText.replace('<'+sTag+'>','[YELL'+sTag+']').replace('</'+sTag+'>','[/YELL'+sTag+']')  
    
      sText=sText.replace('<',' &lt; ').replace('>',' &gt; ')
    
      for(sTag in lsTags) //TODO? change pre into p?
        sText=sText.replace('[YELL'+sTag+']','<'+sTag+'>').replace('[/YELL'+sTag+']','</'+sTag+'>')  
    
      sText=sText.replace('[YELLspan]','<span').replace('[YELLclose]','>').replace('[/YELLspan]','</span>')
      sText=sText.replace('[YELLbr]','<br />')      
    }
    return sText
  }
  static loginf(sStr){
    //Logger.getLogger(Tools.class).debug('112')
  }

  static String transliterate (sPhrase) {
    def alpha = "абвгдеёжзиыйклмнопрстуфхцчшщьэюяъ"
    def _alpha = ["a","b","v","g","d","e","yo","g","z","i","y","i",
                  "k","l","m","n","o","p","r","s","t","u",
                  "f","h","tz","ch","sh","sh","","e","yu","ya",""]
    int k
    def result = ""
    def sPrepPhrase = sPhrase.toLowerCase().replace("'", '').replace(')','').replace('(','').replace('\\','').replace('+','_').replace('№','').replace('@','').replace('#','').replace('"','').replace(',','').replace(';','').replace('.','').replace('%','').replace('?','').replace('!','').replace('/','').trim().replace(' ','_')
    for(int i=0; i<sPrepPhrase.size();i++){
      k = alpha.indexOf(sPrepPhrase[i])
      if(k != -1)
        result += _alpha[k]
      else 
        result += sPrepPhrase[i]
    }
    if(result=='') result = ((ConfigurationHolder.config.linkname.prefix)?ConfigurationHolder.config.linkname.prefix:"arenda_")
    return result
  }

  static String generateSMScode() {
    Random rand = new Random(System.currentTimeMillis())
    return (rand.nextInt().abs() % 89999 + 10000).toString() //10000..99999
  }

  static def getCalendarFilter (monthArr,iMinYear=2012,iMinMinth=0) {
    if (monthArr.size()!=12) return null
    def result = [:]
    def today = new Date()

    result.filterYears = []
    result.filterMonths = []
    result.curYear = today.getYear()+1900
    result.curMonth = today.getMonth()+1
    for (int i = result.curYear; i>=iMinYear; result.filterYears << i-- ){
      def temp = []
      for (int j = (i==result.curYear?result.curMonth-1:11);j>=(i==iMinYear?iMinMinth-1:0);j--){
        temp<<monthArr[j]
      }
      result.filterMonths<<temp
    }

    return result
  }

  static String generateModeParam(lId,lCId) {
    def i = 0
    return generateMD5('_yellcat'+lId+'somesalt'+lCId+'yellcat-').toCharArray().collect{++i; i%4?'':it}.join()
  }
  static String generateModeParam(lId) {
    return generateModeParam(lId,0)
  }

  static String generateNorder(lId,iType) {
    def result = ''
    (6-lId.toString().size()).times{result+='0'}
    return ((ConfigurationHolder.config.payorder.prefix)?ConfigurationHolder.config.payorder.prefix.trim():'st')+new Date().getYear().toString()[-1]+iType.toString()+result+lId.toString()
  }

  static String generateAccountcode(lId,iType) {
    def result = ''
    (6-lId.toString().size()).times{result+='0'}
    return iType.toString()+result+lId.toString()
  }

  static String generatePriceForliqpay(lId) {
    def result = ''
    (10-lId.toString().size()).times{result+='0'}
    return result+lId.toString()+'00'
  }

  static String num2str(long rub,boolean stripkop) {
    def sex = [
      ["","один","два","три","четыре","пять","шесть","семь","восемь","девять"],
      ["","одна","две","три","четыре","пять","шесть","семь","восемь","девять"],
    ];
    def str100= ["","сто","двести","триста","четыреста","пятьсот","шестьсот","семьсот", "восемьсот","девятьсот"];
    def str11 = ["","десять","одиннадцать","двенадцать","тринадцать","четырнадцать", "пятнадцать","шестнадцать","семнадцать","восемнадцать","девятнадцать","двадцать"];
    def str10 = ["","десять","двадцать","тридцать","сорок","пятьдесят","шестьдесят", "семьдесят","восемьдесят","девяносто"];
    def forms = [
      ["копейка", "копейки", "копеек", "1"],
      ["рубль", "рубля", "рублей", "0"],
      ["тысяча", "тысячи", "тысяч", "1"],
      ["миллион", "миллиона", "миллионов", "0"],
      ["миллиард","миллиарда","миллиардов","0"],
      ["триллион","триллиона","триллионов","0"],
    ];

    def moi = rub.toString().split("\\.");
    long kop = Long.valueOf(moi.size()>1?moi[1]:'0');
    if (!((moi.size()>1?moi[1]:'0').substring( 0,1).equals("0")) ){
      if (kop<10 )
        kop *=10;
    }
    String kops = String.valueOf(kop);
    if (kops.length()==1 )
      kops = "0"+kops;
    long rub_tmp = rub;

    ArrayList segments = new ArrayList();
    while(rub_tmp>999) {
      long seg = rub_tmp/1000;
      segments.add( rub_tmp-(seg*1000) );
      rub_tmp=seg;
    }
    segments.add( rub_tmp );
    Collections.reverse(segments);

    String o = "";
    if (rub== 0) {
      o = "ноль "+morph( 0, forms[1][ 0],forms[1][1],forms[1][2]);
      if (stripkop)
        return o;
      else
        return o +" "+kop+" "+morph(kop,forms[ 0][ 0],forms[ 0][1],forms[ 0][2]);
    }

    int lev = segments.size();
    for (int i= 0; i<segments.size(); i++ ) {
      int sexi = (int)Integer.valueOf( forms[lev][3].toString() );
      int ri = (int)Integer.valueOf( segments.get(i).toString() );
      if (ri== 0 && lev>1) {
        lev--;
        continue;
      }
      String rs = String.valueOf(ri);

      if (rs.length()==1) rs = "00"+rs;
      if (rs.length()==2) rs = "0"+rs;

      int r1 = (int)Integer.valueOf( rs.substring( 0,1) );
      int r2 = (int)Integer.valueOf( rs.substring(1,2) );
      int r3 = (int)Integer.valueOf( rs.substring(2,3) );
      int r22= (int)Integer.valueOf( rs.substring(1,3) );

      if (ri>99) o += str100[r1]+" ";
      if (r22>20) {
        o += str10[r2]+" ";
        o += sex[ sexi ][r3]+" ";
      }
      else {
        if (r22>9) o += str11[r22-9]+" ";
        else o += sex[ sexi ][r3]+" ";
      }

      o += morph(ri, forms[lev][ 0],forms[lev][1],forms[lev][2])+" ";
      lev--;
    }

    if (stripkop) {
        o = o.replaceAll(" {2,}", " ");
    }
    else {
        o = o+""+kops+" "+morph(kop,forms[ 0][ 0],forms[ 0][1],forms[ 0][2]);
        o = o.replaceAll(" {2,}", " ");
    }
    return o;
  }
  static String morph(long n, String f1, String f2, String f5) {
    n = Math.abs(n) % 100;
    long n1 = n % 10;
    if (n > 10 && n < 20) return f5;
    if (n1 > 1 && n1 < 5) return f2;
    if (n1 == 1) return f1;
    return f5;
  }

  static def prepareCSVLines(_lsLines,iCount){
    def result = []
    for (int i = 1;i<_lsLines.size();i++){
      def tmp = _lsLines[i]
      while(tmp.split(';',-1).size()<iCount) {
        tmp = tmp + '\n' + _lsLines[++i]
      }
      def str = ''
      def tkn = false
      tmp.split(';',-1).each{
        if (tkn&&it&&it[-1]=='\"') tkn=false;
        if (it&&it[0]=='\"'&&it[-1]!='\"'||tkn){
          str += it.toString()
          tkn = true
        } else
          str += it.toString() + ';'
      }
      result << str
    }
    return result
  }

  static String transformToSecurePhotourl(sUrl) {
    if (!sUrl) {
      return ''
    }
    if(sUrl.startsWith('https://')||!sUrl.startsWith('http'))
      return sUrl
    if(!sUrl.split('http://')[1].startsWith('cs')){
      return sUrl.replace('http://','https://')
    } else {
      return 'https://'+sUrl.split('http://')[1].split('/').collect{if(it.startsWith('cs'))'pp.vk.me/c'+(it.split('\\.')[0]-'cs')else it}.join('/')
    }
  }

  static generateHmacMD5(sText,sSalt) {
    Mac mac = Mac.getInstance("HmacMD5")
    mac.init(new SecretKeySpec(sSalt.getBytes("UTF-8"), "HmacMD5"))
    mac.update(sText.getBytes("UTF-8"))
    return mac.doFinal()
  }

  static getDayString(iTime) {
    def iDaynumber = (iTime-180*60*1000)/(60*60*24*1000) as Integer
    return (iDaynumber>0?iDaynumber+(iDaynumber in 11..20||iDaynumber%10==0||iDaynumber%10 in 5..9?' дней ':iDaynumber%10==1?' день ':' дня '):'')+String.format('%tT',iTime-180*60*1000)
  }

}