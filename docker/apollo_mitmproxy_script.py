import mitmproxy
from mitmproxy import ctx
from base64 import b64encode

origin_client_id = "5JHxEu-4wnFfBA"
custom_client_id = "REPLACE_ME"

authorize_url = f"reddit.com/api/v1/authorize?client_id={origin_client_id}"
wanted_url = f"https://www.reddit.com/api/v1/authorize?client_id={custom_client_id}&response_type=code&state=RedditKit&redirect_uri=apollo://reddit-oauth&duration=permanent&scope=account,creddits,edit,flair,history,identity,livemanage,modconfig,modflair,modlog,modothers,modposts,modself,modwiki,mysubreddits,privatemessages,read,report,save,submit,subscribe,vote,wikiedit,wikiread,modcontributors,modtraffic,modmail,structuredstyles"
access_token_url = "https://www.reddit.com/api/v1/access_token"

class FixApolloToken:
    def response(self, flow: mitmproxy.http.HTTPFlow):
        # check for the URL we want to intercept
        if authorize_url in flow.request.pretty_url:
            ctx.log.info("Intercepted log-in!")
            # replace Apollo's client ID with custom client ID by redirecting
            flow.response = mitmproxy.http.Response.make(
                302, "", {"Location": wanted_url}
            )

class RewriteBasicAuthUsername:
    def request(self, flow: mitmproxy.http.HTTPFlow):
        # check for the URL we want to intercept
        if flow.request.pretty_url == access_token_url:
            ctx.log.info("Intercepted token request!")
            # replace Apollo's client ID with custom client ID in the username field of the HTTP Basic auth header
            flow.request.headers["Authorization"] = f"Basic {b64encode(f'{custom_client_id}:'.encode()).decode()}"

addons = [FixApolloToken(), RewriteBasicAuthUsername()]
