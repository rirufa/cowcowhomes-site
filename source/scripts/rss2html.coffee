SUMMARY_MAX_LEN = 70

class ImageDelayLoader
  @observer = new IntersectionObserver (entries, object) ->
    for i in[0..entries.length - 1]
      e = entries[i]
      if e.isIntersecting
        img = e.target
        img.setAttribute 'src', img.getAttribute('data-src')
        object.unobserve(img)

  @register: (img)->
    @observer.observe(img);

class Parser
  parseData: (json)->
    return json

  getItems: (json)->
    return json

  getLink: (items,i)->
    return ""

  getTitle: (items,i)->
    return ""

  getImage: (items,i)->
    return ""

  getDescription: (items,i)->
    return ""

  getSummaryTitle: (items)->
    return ""

  getSummaryLink: (items)->
    return ""

  hashCode: (str)->
    hash = 0
    i = undefined
    chr = undefined
    if str.length == 0
      return hash
    i = 0
    while i < str.length
      chr = str.charCodeAt(i)
      hash = (hash << 5) - hash + chr
      hash |= 0
      # Convert to 32bit integer
      i++
    hash

  addRssItem: (data, rssbox)->
    if data.length == 0
      return

    json = @parseData(data)

    rss_items = @getItems(json)

    len = rss_items.length
    if len > 10
      len = 10

    root = rssbox.getElementsByClassName('rss-items')[0]
    template = root.getElementsByTagName('template')[0]

    i = 0
    while i < len
      #複製してliタグを得る
      new_li = document.importNode(template.content, true).firstElementChild
      new_a = new_li.getElementsByTagName('a')[0]
      if typeof(new_a) != "undefined"
        new_a.setAttribute 'href', @getLink(rss_items,i)
        new_a.insertAdjacentHTML('afterbegin', @getTitle(rss_items,i))
      new_img = new_li.getElementsByTagName('img')[0]
      if typeof(new_img) != "undefined"
        new_img.setAttribute 'data-src',@getImage(rss_items,i)
        ImageDelayLoader.register(new_img)
      new_desc = new_li.getElementsByClassName('description')[0]
      if typeof(new_desc) != "undefined"
        new_desc.insertAdjacentHTML('afterbegin', @getDescription(rss_items,i))
      random = @hashCode(@getTitle(rss_items,i))
      detail = 
        'content_type': 'product'
        'items': [ {
          'id': '' + random
          'name': @getTitle(rss_items,i)
        } ]
      gtag_text = 'gtag(\'event\',\'select_content\', ' + JSON.stringify(detail) + ')'
      new_a.setAttribute 'onclick', gtag_text
      root.appendChild new_li
      i++
    summary_tag = rssbox.getElementsByClassName('summary')
    if summary_tag.length == 1
      summary = summary_tag[0]
      if summary.getAttribute('href') == ""
        summary.setAttribute 'href', @getSummaryLink(json)
      if summary.innerHTML == ""
        summary.innerHTML = @getSummaryTitle(json)
        gtag_text = 'gtag(\'event\',\'view_search_results\', ' + @getSummaryTitle(json) + ')'
        summary.setAttribute 'onclick', gtag_text
    progress = rssbox.getElementsByTagName('progress')[0]
    progress.style.display = 'none'
    return

class RssParser extends Parser
  getItems: (json)->
    if typeof json['@attributes'] == 'undefined'
      rss_items = json['item']
    else
      rss_items = json.channel?.item
    if typeof rss_items == 'undefined'
      rss_items = []
    #rss_itemが一つしか存在しない場合、配列で取得できない
    else if !Array.isArray(rss_items)
      rss_items = [ rss_items ]
    return rss_items

  getLink: (items,i) ->
    return items[i]['link']

  getTitle: (items,i)->
    return items[i]['title']

  getImage: (items,i)->
    if typeof(items[i]['media_thumbnail@url']) == 'undefined'
      return items[i]['enc_enclosure@resource']
    else
      return items[i]['media_thumbnail@url']

  getDescription: (items,i)->
    if typeof(items[i]['atom_summary']) == 'undefined'
      return items[i]['description'].substring(0,SUMMARY_MAX_LEN) + "..."
    else
      return items[i]['atom_summary'].substring(0,SUMMARY_MAX_LEN) + "..."

  getSummaryTitle: (json)->
    return json['channel']['title']

  getSummaryLink: (json)->
    return json['channel']['link']

class CraiglistParser extends Parser
  getItems: (json)->
    return json

  getLink: (items,i) ->
    return items[i]['link']

  getTitle: (items,i)->
    return items[i]['title'] + " " + items[i]['price']

  getImage: (items,i)->
    return "/image/building_house2.png";

  getDescription: (items,i)->
    return "";

  getSummaryTitle: (json)->
    return "";

  getSummaryLink: (json)->
    return "";

window.addEventListener 'DOMContentLoaded', (->
  rssboxs = document.getElementsByClassName('rss-box')
  i = 0
  while i < rssboxs.length
    #無名関数を使わないとajaxが意図したとおりに実行されない
    do (i) ->
      rssbox = rssboxs[i]
      rss_url = rssbox.getAttribute('data-rss-url')
      if(rss_url != null)
        fetch('/rss/index.php?rss_url=' + rss_url)
        .then (response) -> response.json()      
        .then (json)->
          parser = new RssParser
          parser.addRssItem(json, rssbox)
          return
        return
      craiglist = rssbox.getAttribute('data-craiglist')
      if(craiglist != null)
        fetch('/' + craiglist)
        .then (response) -> response.json()      
        .then (json)->
          parser = new CraiglistParser
          parser.addRssItem(json, rssbox)
          return
        return
    i++
  return
), false

# ---
# generated by js2coffee 2.2.0