lowerlim = 10
afflower = 12
affupper = 14
Upperlim = 12
maxchar = 4600
affpgcount = 1
currpg = 1
affalltext = ""
editmode = false
curoffpage = 0
curselend = 0
affpageoffset = 0
curpage = 1
entereditmode = false
affnode = null

pxtopt = (pixel) ->
  return Math.round(pixel/((.35146/25.4)*96))

maxpgrenum = () ->
  $("[name='mpage']").each ->
    $(this).val affpgcount
  return

pnrenum = () ->
  currpg = 1
  $("[name='pn']").each(pnnum)
  return

pnnum =() ->
  $(this).val(currpg)
  currpg = currpg + 1
  return

newaffpage = (priorpage,ext) ->
  newpage = priorpage.clone(true)
  affpgcount++
  npchild = newpage.find("[name='aff-f-1']")
  priorpage.after newpage
  npchild.val("")
  if(ext.length>maxchar)
    npchild.val(ext.substring(0,maxchar))
    newaffpage(newpage,ext.substring(maxchar))
  else
    npchild.focus()
    maxpgrenum
    pnrenum
  return

getnextline = (text) ->
  #regexp to find chain of letters ending in linefeed or period
  #return line
  exp = new RegExp("(\n|([^\n]*)(\.){1,})")
  result = exp.exec(text)
  if(result[0] == null)
    #Leaving this here just in case
    console.log("Error: Null Regex Value")
    return ""
  return result[0]

placenextline = (page, text) ->
  #recursion, because why not?
  nline = getnextline(text)
  affta = page.find("[name='aff-f-1']")
  #save old val
  oldval = String(affta.val())
  newtext = text.substring(nline.length)
  affta.val(affta.val()+nline)
  #now check scroll height
  #console.log(nline)
  if(affta.prop('scrollHeight') > affta.outerHeight())
    fs = pxtopt(parseInt($(this).css('font-size')))
    while(this.scrollHeight > $(this).outerHeight() && fs != lowerlim)
      $(this).css('font-size', fs+'pt')
      fs--
      if(fs < lowerlim)
        fs = lowerlim
    affta.val(oldval)
    if(affta.prop('scrollHeight') > affta.outerHeight())
      console.log("Error: Page Capacity Exceeded")
    return text
  else
    if(newtext.length == 0)
      return newtext
    else
      return  placenextline(page, newtext)

#grabs text from all affidavit field
affgrabtext = (page) ->
  #grab aff form
  affta = page.find("[name='aff-f-1']")
  affalltext += affta.val()
  if(page.find("[name='pn']").val() < curpage)
    affpageoffset += affta.val().length
  else if(page.find("[name='pn']").val() == curpage)
    #get cursor offset
    curoffpage = affta.prop("selectionStart")
    curselend = affta.prop("selectionEnd")
  if(page.find("[name='pn']").val() != "1")
    page.remove()
  return

#Enter affidavit edit mode
affeditmode = () ->
  affpageoffset = 0
  #reset affalltext
  affalltext = ""
  affpgcount = 1
  $("[name='aff-1']").each ->
    affgrabtext($(this))
  maxpgrenum()
  $("[name='aff-f-1']").val(affalltext)
  $("[name='aff-f-1']").focus()
  $(document).scrollTop($("[name='aff-f-1']").position().top)
  #set cursor position to offset
  $("[name='aff-f-1']").prop("selectionStart", curoffpage+affpageoffset)
  $("[name='aff-f-1']").prop("selectionEnd", curselend+affpageoffset)
  return

extendaff = (extra, priorpage) ->
  newpage = priorpage.clone(true)
  affpgcount++
  newpage.attr("name", "aff-1")
  #Will write recursive search loop later
  newpage.find("[name='pn']").val(affpgcount)
  temp = newpage.find("[name='paffi']")
  temp.attr('name', temp.attr('name'))
  temp = newpage.find("[name='affsig']")
  temp.attr('name', temp.attr('name'))
  temp = newpage.find("[name='date']")
  temp.attr('name', temp.attr('name'))
  temp = newpage.find("[name='affsig2']")
  temp.attr('name', temp.attr('name'))
  temp = newpage.find("[name='tcourt']")
  temp.attr('name', temp.attr('name'))
  npchild = newpage.find("[name='aff-f-1']")
  npchild.attr('name', ("aff-f-1"))
  priorpage.after newpage
  leftovers = placenextline(newpage, extra)
  #npchild.val extra.substring(0,maxchar)
  #Update max pages on every affidavit page
  #priorpage.after newpage
  console.log("Extending")
  maxpgrenum()
  if(leftovers.length > 0)
    console.log("Go the distance")
    extendaff(leftovers, newpage)
  return

$(document).ready ->
  maxpgrenum()
  #$(":input").each ->
  #  if($(this).hasClass('taform') == false)
  #    fontsize = parseInt($(this).css("font-size"))
  #    $(this).css('height', (fontsize)+'px')
  #  return
  $(":input").focusout ->
    if($(this).attr('name')!="aff-f-1")
      ghost = $(":input[name="+$(this).attr('name')+"]")
      ghost.val $(this).val()
      ghost.css('font-size', $(this).css('font-size'))
    return
  $(":checkbox").click ->
    ghost = $(":checkbox[name="+$(this).attr('name')+"]")
    ghost.prop("checked", $(this).prop("checked"))
    return
  $(":checkbox[name^=cr]").click ->
    nametemp = $(this).attr('name')
    if(nametemp.indexOf("-c") >= 0)
      $(this).prop("checked",true)
      nametemp = $(this).attr('name')
      nametemp = nametemp.substring(0,3)
      $("[name="+nametemp+"]").prop('checked', false)
      return
    else
      #no this is disgusting, clean this mess up
      temp = $(this).attr('name')
      c2 = $("[name="+temp+"-c]")
      c2.prop("checked", false)
      $(this).prop("checked", true)
      return
  $(":input").keydown ->
    if(this.scrollHeight > $(this).outerHeight() || this.scrollWidth > $(this).outerWidth())
      fontsize = parseInt($(this).css("font-size"), 10)
      fontsize = pxtopt(fontsize)
      if(fontsize > lowerlim)
        $(this).css('font-size', (fontsize-1) + "pt")
    else if(this.scrollHeight <= $(this).outerHeight() || this.scrollWidth < $(this).outerWidth())
      fontsize = parseInt($(this).css("font-size"), 10)
      fontsize = pxtopt(fontsize)
      if(fontsize < Upperlim || ($(this).hasClass('taform') && fontsize < 12))
        $(this).css('font-size', (fontsize+1) + "pt")
      if(this.scrollWidth > $(this).outerWidth() || this.scrollHeight > $(this).outerHeight())
          fontsize = parseInt($(this).css("font-size"), 10)
          fontsize = pxtopt(fontsize)
          if(fontsize > lowerlim)
            $(this).css('font-size', (fontsize-1) + "pt")
    if(this.scrollHeight > $(this).outerHeight() || this.scrollWidth > $(this).outerWidth())
      if(fontsize <= afflower && $(this).attr('name')!="aff-f-1")
        $(this).val($(this).val().substring(0,$(this).val().length-1))
    return
  $("[name='aff-f-1']").focusout ->
    fs = pxtopt(parseInt($(this).css('font-size')))
    console.log("before extend")
    while(this.scrollHeight > $(this).outerHeight() && fs != lowerlim)
      fs--
      $(this).css('font-size', fs+'pt')
      if(fs < lowerlim)
        fs = lowerlim
    if(this.scrollHeight > $(this).outerHeight())
      affalltext = $(this).val()
      $(this).val ""
      startingpage = $("[name='aff-1']")
      extra = placenextline(startingpage, affalltext)
      #recursive call to handle the rest
      if(extra.length > 0)
        extendaff(extra, startingpage)
    console.log("after extend")
    editmode = false
    entereditmode = false
    return
  $("[name='aff-f-1']").mousedown ->
    if(editmode == false)
      entereditmode = true
      affnode = $(this)
    return
  $(document).mouseup ->
    if(entereditmode == true && editmode == false)
      editmode = true
      curpage = affnode.parent().parent().find("[name='pn']").val()
      affeditmode()
      console.log("end mouseupif")
    return
  $(document).keydown ->
    if(event.which == 8 && !$(event.target).is("input, textarea"))
      e.preventDefault
  return
