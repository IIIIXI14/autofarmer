package com.example.autofarmer;

import android.util.Log;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

public class LogFilter {
    private static final String TAG = "LogFilter";
    private static final String[] FILTERED_TAGS = {
        "libEGL",
        "EGL_emulation",
        "OpenGLRenderer"
    };

    public static void install() {
        Thread filterThread = new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    String[] command = new String[] { "logcat", "-c" };
                    Runtime.getRuntime().exec(command);
                    
                    command = new String[] { "logcat" };
                    Process process = Runtime.getRuntime().exec(command);
                    BufferedReader bufferedReader = new BufferedReader(
                        new InputStreamReader(process.getInputStream())
                    );

                    String line;
                    while ((line = bufferedReader.readLine()) != null) {
                        boolean shouldFilter = false;
                        for (String filteredTag : FILTERED_TAGS) {
                            if (line.contains(filteredTag)) {
                                shouldFilter = true;
                                break;
                            }
                        }
                        if (!shouldFilter) {
                            Log.d(TAG, line);
                        }
                    }
                } catch (IOException e) {
                    Log.e(TAG, "Failed to filter logs", e);
                }
            }
        });
        filterThread.start();
    }

    public static void clearLogs() {
        try {
            Runtime.getRuntime().exec("logcat -c");
        } catch (IOException e) {
            Log.e(TAG, "Failed to clear logs", e);
        }
    }
} 