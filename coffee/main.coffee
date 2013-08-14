lowerlim = 9
Upperlim = 12
maxchar = 4600
affpgcount = 1
currpg = 1

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
  npchild = newpage.children().children().children("[name='aff-f-1']")
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


keydownhandler = (event) ->
  if(event.which==8)
    if($(':focus').val().length == 0 && affpgcount != 1)
      rmpg = $(':focus').parent().parent().parent()
      psib = rmpg.prev()
      psib.children().children().children("[name='aff-f-1']").focus()
      nodeta = psib.children().children().children("[name='aff-f-1']")
      temp = nodeta.val()
      nodeta.val("")
      nodeta.val(temp)
      rmpg.remove()
      affpgcount = affpgcount - 1
      maxpgrenum()
      pnrenum()
  else
    if($(':focus').val().length > maxchar)
      node = $(':focus').parent().parent().parent()
      if(affpgcount == 1)
        txt = $(":focus").val()
        if(txt.length > maxchar)
          extratxt=txt.substring(maxchar)
          $(":focus").val(txt.substring(0,maxchar))
        else
          extratxt=""
        newaffpage(node,extratxt)
  return

extendaff = (extra, priorpage) ->
  newpage = priorpage.clone(true)
  affpgcount++
  newpage.attr("name", "aff-1")
  #Will write recursive search loop later
  newpage.children().children().children().children().children().children("[name='pn']").val(affpgcount)
  temp = newpage.children().children().children().children().children().children().children("[name='paffi']")
  temp.attr('name', temp.attr('name'))
  temp = newpage.children().children().children().children().children().children().children("[name='affsig']")
  temp.attr('name', temp.attr('name'))
  temp = newpage.children().children().children().children().children().children("[name='date']")
  temp.attr('name', temp.attr('name'))
  temp = newpage.children().children().children().children().children().children("[name='affsig2']")
  temp.attr('name', temp.attr('name'))
  temp = newpage.children().children().children().children().children("[name='tcourt']")
  temp.attr('name', temp.attr('name'))
  npchild = newpage.children().children().children("[name='aff-f-1']")
  npchild.attr('name', ("aff-f-1"))
  leftovers = extra.substring(maxchar)
  npchild.val extra.substring(0,maxchar)
  #Update max pages on every affidavit page
  priorpage.after newpage
  maxpgrenum()
  if(leftovers.length > 0)
    extendaff(leftovers, newpage)
  return

$(document).ready ->
  $(":input").focusout ->
    if($(this).attr('name')!="aff-f-1")
      ghost = $(":input[name="+$(this).attr('name')+"]")
      ghost.val $(this).val()
      ghost.css('font-size', $(this).css('font-size'))
    return
  $(":checkbox").click ->
    ghost = $(":checkbox[name="+$(this).attr('name')+"-g]")
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
      return
    else if(this.scrollHeight < $(this).outerHeight() || this.scrollWidth < $(this).outerWidth())
      fontsize = parseInt($(this).css("font-size"), 10)
      fontsize = pxtopt(fontsize)
      if(fontsize < Upperlim)
        $(this).css('font-size', (fontsize+1) + "pt")
      return
  $("[name='aff-f-1']").focusout ->
    #  fs = pxtopt(parseInt($(this).css('font-size')))
    #  while(this.scrollHeight > $(this).outerHeight() && fs > lowerlim)
      #  $(this).css('font-size', fs+'pt')
      #  fs--
    # if($(this).val().length > maxchar)
    #  ss = $(this).val().substring(maxchar)
    #  $(this).val $(this).val().substring(0,maxchar)
    #  startingpage = $("[name='aff-1']")
      #recursive call to handle the rest
      #  if(ss.length > 0)
      #   extendaff(ss, startingpage)
      #  return
  $("[name='aff-f-1']").keydown ->
    keydownhandler(event)
    return
  $(document).keydown ->
    if(event.which == 8 && !$(event.target).is("input, textarea"))
      e.preventDefault
  return
