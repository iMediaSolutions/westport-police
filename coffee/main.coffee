lowerlim = 9
maxchar = 4600
affpgcount = 1

pxtopt = (pixel) ->
  return Math.round(pixel/((.35146/25.4)*96))

maxpgrenum = () ->
  $("[name='mpage']").each ->
    $(this).val affpgcount
  return

extendaff = (extra, priorpage) ->
  newpage = priorpage.clone()
  affpgcount++
  newpage.attr("name", "aff-"+affpgcount)
  #Will write recursive search loop later
  newpage.children().children().children().children().children().children("[name='pn']").val(affpgcount)
  temp = newpage.children().children().children().children().children().children().children("[name='paffi']")
  temp.attr('name', temp.attr('name')+"-g")
  temp = newpage.children().children().children().children().children().children().children("[name='affsig']")
  temp.attr('name', temp.attr('name')+"-g")
  temp = newpage.children().children().children().children().children().children("[name='date']")
  temp.attr('name', temp.attr('name')+"-g")
  temp = newpage.children().children().children().children().children().children("[name='affsig2']")
  temp.attr('name', temp.attr('name')+"-g")
  temp = newpage.children().children().children().children().children("[name='tcourt']")
  temp.attr('name', temp.attr('name')+"-g")
  string = "aff-f-"+(affpgcount-1)
  npchild = newpage.children().children().children("[name='"+string+"']")
  npchild.attr('name', ("aff-f-"+affpgcount))
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
    ghost = $(":input[name="+$(this).attr('name')+ "-g]")
    ghost.val $(this).val()
    ghost.css('font-size', $(this).css('font-size'))
    return
  $(":checkbox").click ->
    ghost = $(":checkbox[name="+$(this).attr('name')+"-g]")
    ghost.prop("checked", $(this).prop("checked"))
    return
  $(":input").keydown ->
    if(this.scrollHeight > $(this).outerHeight() || this.scrollWidth > $(this).outerWidth())
      fontsize = parseInt($(this).css("font-size"), 10)
      fontsize = pxtopt(fontsize)
      if(fontsize > lowerlim)
        $(this).css('font-size', (fontsize-1) + "pt")
      return
  $("[name='aff-f-1']").focusout ->
    fs = pxtopt(parseInt($(this).css('font-size')))
    while(this.scrollHeight > $(this).outerHeight() && fs > lowerlim)
      $(this).css('font-size', fs+'pt')
      fs--
    if($(this).val().length > maxchar)
      ss = $(this).val().substring(maxchar)
      $(this).val $(this).val().substring(0,maxchar)
      startingpage = $("[name='aff-1']")
      #recursive call to handle the rest
      if(ss.length > 0)
       extendaff(ss, startingpage)
      return
  return



