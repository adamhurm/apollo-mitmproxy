# How to keep using Apollo after Reddit API changes
No jailbreak or developer certificates required!

- [Download](#download-apollo-ipa) and [install](#install-apollo-ipa) Apollo IPA
- [Get a personal API token](#create-custom-reddit-app-and-get-client_id)
- [Replace the client_id](#use-mitmproxy-to-replace-client_id) in [docker/apollo_mitmproxy_script.py](https://github.com/adamhurm/apollo-mitmproxy/blob/main/docker/apollo_mitmproxy_script.py#L6) (Line 6)

## Docker / K8s
The proxy (port 30000) and the mitmweb GUI (port 30001) are exposed as NodePorts. You can modify this to use nip.io if you remove the commented lines in [build.sh](./build.sh) and add your local IP to the [manifest files](./k8s/nip.io/ingess.yml). There is also optional support for [docker compose](./docker).
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
ℹ️ This step requires Windows to use the older iTunes version.

Follow [this guide](https://github.com/qnblackcat/How-to-Downgrade-apps-on-AppStore-with-iTunes-and-Charles-Proxy) to get Apollo 1.15.9 IPA with iTunes 12.6.5 and Charles Proxy.
1. Set up an interactive https proxy ([mitmproxy](https://mitmproxy.org/),[Burp](https://portswigger.net/burp/communitydownload),[Charles](https://www.charlesproxy.com/download/)).
2. Configure your system's network connection to use proxy from step 1. 
3. Capture the request that downloads Apollo from iTunes:
   Edit `p*-buy.itunes.apple.com/WebObjects/MZBuy.woa/wa/buyProduct` request and replace `appExtVersId` with `857705900` (Apollo Version 1.15.9)

📝 This IPA is encrypted and tied to the Apple ID that was used in iTunes when it was downloaded. You can't use this IPA across different Apple IDs without re-signing (requires developer certificate) or disabling app signing (requires jailbreak).

### Install Apollo IPA
ℹ This step requires macOS

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
Copy _client_id_ under the created application. This will be used in `apollo_mitmproxy_script.py`.

### Use mitmproxy to replace client_id
Replace _client_id_ in [docker/apollo_mitmproxy_script.py](./docker/apollo_mitmproxy_script.py) (credit to [No-Cherry-5766](https://www.reddit.com/r/apolloapp/comments/14iub7y/comment/jpjqaf5/)):

```python
# apollo_mitmproxy_script.py
custom_client_id = "REPLACE_ME" <----
```

If you want to use this outside of docker, run mitmproxy with the script:

```bash
$ brew install mitmproxy
$ mitmdump -s apollo_mitmproxy_script.py
```

### Configure proxy on iOS device
On iOS, open your Wi-Fi network configuration and set up a "Manual" proxy pointing to macOS machine's local IP and port 30000 (or default 8080 for mitmproxy).<br>
In Safari, download CA certificate via http://mitm.it.<br>
In Settings, trust downloaded profile twice (second one is hidden under General > About > Certificate Trust Settings).

Open Apollo and sign in. You should see the name of your custom app on the OAuth prompt before clicking "Allow".

Enjoy! Now you can turn off the proxy configuration. You may also want to delete profiles if you are not actively using them.

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
