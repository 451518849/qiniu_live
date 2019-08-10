package com.xiaofa.qiniu_live.live;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.util.Log;
import android.widget.Toast;

import com.google.gson.Gson;
import com.qiniu.droid.rtc.QNCustomMessage;
import com.qiniu.droid.rtc.QNErrorCode;
import com.qiniu.droid.rtc.QNRTCEngine;
import com.qiniu.droid.rtc.QNRTCEngineEventListener;
import com.qiniu.droid.rtc.QNRTCSetting;
import com.qiniu.droid.rtc.QNRoomState;
import com.qiniu.droid.rtc.QNSourceType;
import com.qiniu.droid.rtc.QNStatisticsReport;
import com.qiniu.droid.rtc.QNTrackInfo;
import com.qiniu.droid.rtc.model.QNAudioDevice;
import com.xiaofa.qiniu_live.QiniuLivePlugin;
import com.xiaofa.qiniu_live.utils.QNAppServer;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;

public class AudioLive implements QNRTCEngineEventListener {

    public EventChannel.EventSink eventCallback;

    public Context context;
    private Toast mLogToast;
    private QNTrackInfo mLocalAudioTrack;
    private QNRTCEngine mEngine;
    private List<QNTrackInfo> mLocalTrackList;
    private boolean mIsJoinedRoom = false;
    public String roomToken;
    private boolean mMicEnabled = true;
    private boolean mSpeakerEnabled = true;
    public String roomName;
    public String appId;
    public Map userData;

    private static AudioLive instance;
    private AudioLive (){}

    //单例
    public static AudioLive getSingleton() {
        if (instance == null) {                         //Single Checked
            synchronized (AudioLive.class) {
                if (instance == null) {                 //Double Checked
                    instance = new AudioLive();
                }
            }
        }
        return instance ;
    }

    private void logAndToast(final String msg) {
        if (mLogToast != null) {
            mLogToast.cancel();
        }
        mLogToast = Toast.makeText(context, msg, Toast.LENGTH_SHORT);
        mLogToast.show();
    }

    public void leaveRoom(){
        mEngine.leaveRoom();
    }

    public void unPublish(){
        mEngine.unPublish();
    }

    public void publishAudio(){
        System.out.println("this.roomToken:"+this.roomToken);
        if(this.roomToken.equals("")){
            new Thread(new Runnable() {
                @Override
                public void run() {
                    final String token = QNAppServer.getInstance().requestRoomToken(context, userData.get("user_id").toString(), roomName);
                    System.out.println("token1:"+token);
                    initAudio(token);
                }
            }).start();
        }else {
            initAudio(this.roomToken);
        }


    }

    private void initAudio(String token){
        initQNRTCEngine();
        initLocalTrackInfoList();
        Gson gson = new Gson();
        mEngine.joinRoom(token,gson.toJson(userData));
    }

    private void initQNRTCEngine() {
        mEngine = QNRTCEngine.createEngine(context, this);
    }

    private void initLocalTrackInfoList() {
        mLocalTrackList = new ArrayList<>();
        mLocalAudioTrack = mEngine.createTrackInfoBuilder()
                .setSourceType(QNSourceType.AUDIO)
                .setMaster(true)
                .create();
        mLocalTrackList.add(mLocalAudioTrack);
    }

    public void destroy() {
        if (mEngine != null) {
            mEngine.destroy();
            mEngine = null;
        }
    }

    @Override
    public void onRoomStateChanged(QNRoomState state) {
        switch (state) {
            case RECONNECTING:
                logAndToast("重新连接");
                break;
            case CONNECTED:
                mEngine.publishTracks(mLocalTrackList);
                logAndToast("连接成功");
                mIsJoinedRoom = true;
                break;
            case RECONNECTED:
                logAndToast("重连成功");
                break;
            case CONNECTING:
                logAndToast("正在连接");
                break;
        }
    }

    public boolean onToggleMic() {
        if (mEngine != null && mLocalAudioTrack != null) {
            mMicEnabled = !mMicEnabled;
            mLocalAudioTrack.setMuted(!mMicEnabled);
            mEngine.muteTracks(Collections.singletonList(mLocalAudioTrack));
        }
        return mMicEnabled;
    }

    public boolean onToggleSpeaker() {
        if (mEngine != null) {
            mSpeakerEnabled = !mSpeakerEnabled;
            mEngine.muteRemoteAudio(!mSpeakerEnabled);
        }
        return mSpeakerEnabled;
    }

    private void jsonToMap(String s,String op){
        Gson gson = new Gson();
        Map user = gson.fromJson(s,Map.class);
        Map json = new HashMap();
        json.put("user",user);
        json.put("op",op);
        if (eventCallback != null){
            eventCallback.success(json);
        }
    }


    @Override
    public void onRemoteUserJoined(String s, String s1) {
        System.out.println("onRemoteUserJoined:"+s+" "+s1);
        if (!s.equals("") && !s1.equals("")){
            jsonToMap(s1,"join");
        }
    }

    @Override
    public void onRemoteUserLeft(String s) {
        if (!s.equals("")){
            jsonToMap(s,"leave");
        }
    }

    @Override
    public void onLocalPublished(List<QNTrackInfo> list) {
        mEngine.enableStatistics();
    }

    @Override
    public void onRemotePublished(String s, List<QNTrackInfo> list) {

    }

    @Override
    public void onRemoteUnpublished(String s, List<QNTrackInfo> list) {

    }

    @Override
    public void onRemoteUserMuted(String s, List<QNTrackInfo> list) {

    }

    @Override
    public void onSubscribed(String s, List<QNTrackInfo> list) {

    }

    @Override
    public void onKickedOut(String s) {

    }

    @Override
    public void onStatisticsUpdated(QNStatisticsReport qnStatisticsReport) {
    }

    @Override
    public void onAudioRouteChanged(QNAudioDevice qnAudioDevice) {

    }

    @Override
    public void onCreateMergeJobSuccess(String s) {

    }

    @Override
    public void onError(int errorCode, String description) {
        if (errorCode == QNErrorCode.ERROR_TOKEN_INVALID
                || errorCode == QNErrorCode.ERROR_TOKEN_ERROR
                || errorCode == QNErrorCode.ERROR_TOKEN_EXPIRED) {
            logAndToast("roomToken 错误，请重新加入房间");
        } else if (errorCode == QNErrorCode.ERROR_AUTH_FAIL
                || errorCode == QNErrorCode.ERROR_RECONNECT_TOKEN_ERROR) {
            // rejoin Room
            mEngine.joinRoom(roomToken);
        } else if (errorCode == QNErrorCode.ERROR_PUBLISH_FAIL) {
            logAndToast("发布失败，请重新加入房间发布");
        } else {
            logAndToast("errorCode:" + errorCode + " description:" + description);
        }
    }

    @Override
    public void onMessageReceived(QNCustomMessage qnCustomMessage) {

    }
}
