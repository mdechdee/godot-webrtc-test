# Godot 4.0 WebRTC serverless multiplayer with Firebase Firestore + Cloud Function integration as signaling server

This is a simple online serverless multiplayer project made using Godot 4.0 beta 10 and [WebRTC GDNative Plugin for Godot](https://github.com/godotengine/webrtc-native).

WebRTC is a peer-to-peer connection using the signaling server which is implemented using Google Cloud function and Firebase, so the hosting cost is very cheap (basically no server required)


To test the project, 
1. Run the main scene (3d-multiplayer.tscn) with 2+ instances 
2. Set the peer_id of all the instances differently by using spinbox on the top left
3. Click host button on one of the instances
4. Wait for the room ID to be generated, then copy the room ID from the host and paste it to the other instances
5. Click join button on all the instances other than the hosts and wait for the connection
6. If connection is successful, player scene will be spawn automatically on all of the instances

> Note that sometimes the connection might not be successful, you can simply try it multiple times by running all the instances again.

Here is a sequence diagram of how the connection works
 ![image](https://user-images.githubusercontent.com/44646767/210538572-a154a270-eb68-40f4-aafa-aa9e9913c8b6.png)
