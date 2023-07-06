# How to keep using Apollo after Reddit API changes
No jailbreak or developer certificates required! Tested on iOS 16.5.1.

Follow the Guide below:
- [Download](#download-apollo-ipa) and [install](#install-apollo-ipa) Apollo IPA
- [Get a personal API token](#create-custom-reddit-app-and-get-client_id)
- [Replace the client_id](#use-mitmproxy-to-replace-client_id) in [docker/apollo_mitmproxy_script.py](https://github.com/adamhurm/apollo-mitmproxy/blob/main/docker/apollo_mitmproxy_script.py#L6) (Line 6)


Create docker image and run in k8s deployment. Right now this exposes the proxy (port 30000) and the mitmweb GUI (port 30001) as NodePorts. (optional support for `docker compose`)
```
chmod +x build.sh
./build.sh
```

- [Configure device proxy](#configure-proxy-on-iOS-device)
  - Server: IP of node that is running k8s pod
  - Port: 30000

Unfortunately this solution relies on a OAuth token refresh after 24h. That means you'll need to set up the proxy once a day. A much cleaner solution is to use `mitmweb --mode wireguard` so that you can toggle it once a day instead of having to type in proxy configuration. I can't find a way to get it working in docker at the moment since wireguard mode is in beta and it doesn't appear to support listening on all interfaces.


# Guide
This is a summary of a few different guides. All credit to the [References](#references) for creating the solution below.

### Download Apollo IPA
ℹ️ Windows is required for this portion due to the older version of iTunes.

Follow [this guide](https://github.com/qnblackcat/How-to-Downgrade-apps-on-AppStore-with-iTunes-and-Charles-Proxy) to get Apollo 1.15.9 IPA with iTunes 12.6.5 and Charles Proxy.

Essentially use any system proxy when downloading Apollo from iTunes to capture HTTP traffic. Then edit `p*-buy.itunes.apple.com/WebObjects/MZBuy.woa/wa/buyProduct`
request and replace `appExtVersId` with `857705900` (Apollo Version 1.15.9)

📝 This IPA is encrypted and tied to the Apple ID that was used in iTunes when it was downloaded. You can't use this IPA across different Apple IDs without re-signing (requires developer certificate) or disabling app signing (requires jailbreak).

### Install Apollo IPA
ℹ The rest of this guide uses macOS.

On your iOS device, open Settings and go to General > iPhone Storage > Apollo in order to "Offload App".

Now we want to remove the app from its packaging so that it is no longer associated with an app receipt. This is necessary to prevent an individual app from updating because the alternative is disabling iOS app updates system-wide.

```bash
$ unzip "Apollo 1.15.9.ipa" -d apollo_unpacked
$ brew install ios-deploy
$ ios-deploy -b apollo_unpacked/Payload/Apollo.app
```

### Create custom reddit app and get client_id
[https://www.reddit.com/prefs/apps](https://www.reddit.com/prefs/apps)<br>
Create a new "Installed App" and set "redirect uri": `apollo://reddit-oauth`<br>
Copy client_id under the created application. This will be used in `apollo_mitmproxy_script.py`.

### Use mitmproxy to replace client_id
Replace client_id in docker/apollo_mitmproxy_script.py

```python
# apollo_mitmproxy_script.py
custom_client_id = "REPLACE_ME" <----
```

```bash
$ brew install mitmproxy
$ mitmdump -s apollo_mitmproxy_script.py
```

### Configure proxy on iOS device
On iOS, open your Wi-Fi network configuration and set up a "Manual" proxy pointing to macOS machine's local IP and port 8080 (default for mitmproxy, you can change this).<br>
In Safari, download CA certificate via http://mitm.it.<br>
In Settings, trust downloaded profile twice (second one is hidden under General > About > Certificate Trust Settings).

Open Apollo and sign in. You should see the name of your custom app on the OAuth prompt before clicking "Allow".

Enjoy! Now you can turn off any proxy configuration and delete any profiles created.

## To-do
- [ ] add details on how to block apolloreq.com
- [ ] turn the IPA download process into a mitmproxy script

------
# References
- https://www.reddit.com/r/apolloapp/comments/14o2b0p/downgrade_and_get_apollo_working_wout_having_a/
- https://github.com/qnblackcat/How-to-Downgrade-apps-on-AppStore-with-iTunes-and-Charles-Proxy
- https://www.reddit.com/r/apolloapp/comments/14iub7y/backup_apollo_app_version_0159_if_you_want_to_use/jpjqaf5/?context=3
- https://medium.com/f-a-t-e/how-to-prevent-an-individual-ios-app-from-updating-forever-b27bcef74465
------
