require './register'
require './client'

# Mastodonの最低限的な機能を実装しているクラス
class SimpleMastodon
  include Register

  NOTIFICATIONS_SINCE_FILE = ".notifications_since"
  LTL_SINCE_FILE = ".ltl_since"

  def initialize
    @client = init_app
  end

  # LTLを取得する。取得するデータは名前とusername, content
  def local_time_line(ltl_since)
    ret_val = []
    @client.public_timeline(since_id: ltl_since, local: true).each do |status|
      ret_val << extract_from_status(status)
    end
    File.write(LTL_SINCE_FILE, @ltl_since.to_s)

    # 時系列順にするためreverseを行う
    ret_val.reverse
  end

  # tootする。visibilityはvisibility, toはin_reply_to_idを表している
  def toot(content, spoiler = '')
    @client.create_status(content, spoiler)
  end

  # HTMLタグを削除したり、改行コードを改行に変化させるメソッド
  def content_convert(content)
    content.gsub!("<br \/>", "\n")
    remove_tag(content)
  end

  # clientがselfになっていたため@clientに変更したperform_requestにした
  def perform_request(request_method, path, options = {})
    Mastodon::REST::Request.new(@client, request_method, path, options).perform
  end

  # statusからdisplay_name, username, contentを取得するメソッド
  def extract_from_status(status)
    account = status.account
    content = status.content

    # display_nameを取得する方法がattributesから直接引っ張ってくるしかなかった
    display = account.attributes["display_name"]
    display ||= account.acct
    { id: account.id, display: display, username: account.username, content: content_convert(content) }
  end

  def remove_tag(str)
    str.gsub(/<([^>]+)>/, "")
  end
end
