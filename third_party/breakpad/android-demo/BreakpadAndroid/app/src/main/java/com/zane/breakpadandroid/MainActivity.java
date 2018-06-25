package com.zane.breakpadandroid;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;

import com.chodison.mybreakpad.NativeMyBreakpadListener;
import com.chodison.mybreakpad.NativeMybreakpad;
import com.chodison.mybreakpad.NativeCrashInfo;

import java.io.File;

import io.reactivex.Observable;
import io.reactivex.ObservableEmitter;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.annotations.NonNull;
import io.reactivex.functions.Consumer;
import io.reactivex.schedulers.Schedulers;

/**
 * 说明：
 *      1、点击 crash 制造 crash (app 闪退)
 *      2、点击 process 解析
 *
 *      3、重新进入 app 之后检查是否存在 dump 文件, 存在则解析并"上传文件"(<-假装的啊, 现在木有后台), 随后删除文件 (待定)
 *
 * 作者：zhouzhan
 * 日期：17/8/15 14:14
 */
public class MainActivity extends AppCompatActivity {

    private static final String TAG = MainActivity.class.getSimpleName();

    private static File externalFile;
    private String dumpDir;
    private static NativeMybreakpad mNativeMybreakpad;

    private static final String[] app_so = {"libtest1.so","libmybreakpad.so","libtest2.so"};

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        externalFile = this.getExternalFilesDir(null);
        mNativeMybreakpad = NativeMybreakpad.getInstance();

        mNativeMybreakpad.setOnEventListener(new NativeMyBreakpadListener.OnEventListener() {
            @Override
            public void onInitEvent(int what, int arg1) {
                Log.e(TAG, "onInitEvent,what:"+what+",arg1:"+arg1);
            }

            @Override
            public void onProcessEvent(int what, int arg1) {
                Log.e(TAG, "onProcessEvent,what:"+what+",arg1:"+arg1);
            }
        });
        Log.e(TAG, "externalFile: " + externalFile);
        if (externalFile != null && externalFile.exists()) {
            dumpDir = externalFile.getPath() +"/dumps";
            checkDir();
            mNativeMybreakpad.init(getApplicationContext(),dumpDir);
        }
    }

    public void doClick(View view){
        int id = view.getId();
        switch (id){
            case R.id.bt_crash:
                NativeMybreakpad.testNativeCrash();
                break;
            case R.id.bt_processor:
                doProcess();
                break;
            case R.id.bt_symbols:
                doProcessSymbols();
                break;
        }
    }

    /**
     * 解析 dump 文件
     */
    private void doProcess() {
        Observable.create(new ObservableOnSubscribe<Boolean>() {
            @Override
            public void subscribe(@NonNull ObservableEmitter<Boolean> e) {
                File dir = new File(dumpDir);
                File[] files = dir.listFiles();
                for (File file : files) {
                    String fileName = file.getName();
                    String lastName = ".dmp";
                    int lastIndexOf = fileName.lastIndexOf(lastName);

                    if (lastIndexOf + lastName.length() == fileName.length()) { // 说明 .dmp 是后缀名
                        String dumpPath = file.getAbsolutePath();
                        String crashFileName = dumpDir + "/" + fileName+ "crash.txt";

                        Log.e(TAG, "crash processed begin,dumpPath: " + dumpPath);
                        NativeCrashInfo crashInfo = mNativeMybreakpad.dumpFileProcessinfo(dumpPath, crashFileName, app_so);
                        if(crashInfo != null){
                            String[] crashSoName = crashInfo.crashSoName;
                            String[] crashSoAddr = crashInfo.crashSoAddr;
                            int existAppSo = crashInfo.exist_app_so;
                            Log.e(TAG, "exist app so crash: " + existAppSo);
                            Log.e(TAG, "first crash so name: " + crashInfo.firstCrashSoName);
                            if(existAppSo == 1) {
                                for (int i = 0; i < crashSoName.length; i++) {
                                    Log.e(TAG, "crash so name[" + i + "]: " + crashSoName[i]);
                                    Log.e(TAG, "crash so text[" + i + "]: " + crashSoAddr[i]);
                                }
                            }
                            Log.e(TAG, "crash processed success");
                        } else {
                            Log.e(TAG, "crash processed failed");
                        }
                    }
                }
            }
        }).subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new Consumer<Boolean>() {
                    @Override
                    public void accept(Boolean aBoolean) throws Exception {

                    }
                });
    }

    /**
     * 生成 symbols 文件
     */
    private void doProcessSymbols() {
        Observable.create(new ObservableOnSubscribe<Boolean>() {
            @Override
            public void subscribe(@NonNull ObservableEmitter<Boolean> e) throws Exception {
                File dir = new File(dumpDir);
                File[] files = dir.listFiles();
                for (File file : files) {
                    String fileName = file.getName();
                    String lastName = ".so";
                    int lastIndexOf = fileName.lastIndexOf(lastName);

                    if (lastIndexOf + lastName.length() == fileName.length()) { // 说明 .so 是后缀名
//                        String dumpPath = file.getAbsolutePath();
//                        String symFileName = DUMP_DIR +"/" + fileName+".sym";
//                        boolean exec = DumpSymbols.exec(new String[]{"./dump_syms", dumpPath, symFileName});
//                        e.onNext(exec);
                    }
                }
            }
        }).subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new Consumer<Boolean>() {
                    @Override
                    public void accept(Boolean aBoolean) throws Exception {
                        Log.e(TAG, "chodison Exec ===> processed: " + aBoolean);

                    }
                });
    }

    /**
     * 检查是否存在 dump 文件夹, 木有则创建
     */
    private void checkDir() {
        Observable.create(new ObservableOnSubscribe<Boolean>() {
            @Override
            public void subscribe(@NonNull ObservableEmitter<Boolean> e) throws Exception {
                if (externalFile == null) {
                    e.onNext(false);
                    return;
                }
                if (!externalFile.exists()) {
                    e.onNext(false);
                    return;
                }
                File dir = new File(dumpDir);
                if (dir.exists() && dir.isDirectory()){
                    e.onNext(true);
                    return;
                }
                // 创建文件夹
                boolean mkdir = dir.mkdir();
                e.onNext(mkdir);
            }
        }).subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new Consumer<Boolean>() {
                    @Override
                    public void accept(Boolean aBoolean) throws Exception {
                        Log.e(TAG, "checkDir: " + aBoolean);
                    }
                });
    }
}
