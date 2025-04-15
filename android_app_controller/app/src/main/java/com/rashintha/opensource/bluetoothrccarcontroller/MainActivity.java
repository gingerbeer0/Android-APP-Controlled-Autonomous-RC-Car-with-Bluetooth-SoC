package com.rashintha.opensource.bluetoothrccarcontroller;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Handler;
import android.os.Message;
import android.support.v4.util.ArraySet;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ImageButton;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Set;
import java.util.UUID;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;

public class MainActivity extends AppCompatActivity implements SensorEventListener {

    final int BLUETOOTH_MSG_STATE = 0;

    private BluetoothAdapter bluetoothAdapter;
    private ImageButton btnBluetoothEnable;
    private Set<BluetoothDevice> pairedDevices;
    private BluetoothSocket socket;

    private ConnectedThread connectedThread;

    private String rcStatus = "n";
    Handler bluetoothHandler;

    private SensorManager sensorManager;
    private Sensor gyroSensor;

    private float[] gyroValues = new float[3]; // [X, Y, Z] 방향의 값 저장
    private boolean isGyroMode = false; // 자이로 모드 활성화 상태
    private boolean isSoundDetectMode = false;
    private String currentMode = "RC CAR";

    private boolean isMusicOn = false;

    // SPP UUID service
    private static final UUID BTMODULEUUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");

    @Override
    protected void onResume() {
        super.onResume();

        if(bluetoothAdapter.isEnabled()){
            btnBluetoothEnable.setImageResource(R.mipmap.bluetooth_enable_true);
        }else{
            btnBluetoothEnable.setImageResource(R.mipmap.bluetooth_enable);
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        ImageButton btnStop = (ImageButton) findViewById(R.id.btnStop);
        ImageButton btnUp = (ImageButton) findViewById(R.id.btnUp);
        ImageButton btnDown = (ImageButton) findViewById(R.id.btnDown);
        ImageButton btnLeft = (ImageButton) findViewById(R.id.btnLeft);
        ImageButton btnRight = (ImageButton) findViewById(R.id.btnRight);
        btnBluetoothEnable = (ImageButton) findViewById(R.id.btnBluetoothEnable);
        ImageButton btnBluetoothConnect = (ImageButton) findViewById(R.id.btnBluetoothConnect);
        ImageButton btnBluetoothDisconnect = (ImageButton) findViewById(R.id.btnBluetoothDisconnect);
        ImageButton btnMusic = (ImageButton) findViewById(R.id.btnMusic);
        TextView btnAutonomous = (TextView) findViewById(R.id.btnAutonomous);
        TextView btnManual = (TextView) findViewById(R.id.btnManual);
        TextView btnGyro = (TextView) findViewById(R.id.btnGyro);
        TextView tvMode = (TextView) findViewById(R.id.tvMode);
        TextView btnSoundDetect = (TextView) findViewById(R.id.btnSoundDetect);

        tvMode.setText(currentMode);

        // SensorManager 초기화
        sensorManager = (SensorManager) getSystemService(SENSOR_SERVICE);
        gyroSensor = sensorManager.getDefaultSensor(Sensor.TYPE_GYROSCOPE);

        if (gyroSensor != null) {
            sensorManager.registerListener(this, gyroSensor, SensorManager.SENSOR_DELAY_NORMAL);
        } else {
            Toast.makeText(this, "Gyro Sensor not available", Toast.LENGTH_SHORT).show();
        }

        /*btnAutonomous.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                switch (event.getAction()){
                    case MotionEvent.ACTION_DOWN:
                        rcStatus = "a";
                        return  true;
                    case MotionEvent.ACTION_UP:
                        rcStatus = "n";
                        return  true;
                }
                return false;
            }
        });*/

        btnGyro.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                isGyroMode = !isGyroMode; // 자이로 모드 ON/OFF 전환
                if (isGyroMode) {
                    currentMode = "GYRO";
                    rcStatus = "m";
                    Toast.makeText(getApplicationContext(), "Gyro mode activated.", Toast.LENGTH_SHORT).show();
                } else {
                    currentMode = "Manual";
                    Toast.makeText(getApplicationContext(), "Gyro mode deactivated.", Toast.LENGTH_SHORT).show();
                }
                tvMode.setText(currentMode);
            }
        });

        btnAutonomous.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                isGyroMode = false;
                currentMode = "AUTO";
                tvMode.setText(currentMode);
                    rcStatus = "a";
                    Toast.makeText(getApplicationContext(), "Autonomous driving mode on.", Toast.LENGTH_SHORT).show();
            }
        });

        btnManual.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                isGyroMode = false;
                currentMode = "MANUAL";
                tvMode.setText(currentMode);
                rcStatus = "m";
                Toast.makeText(getApplicationContext(), "Manual driving mode on.", Toast.LENGTH_SHORT).show();
            }
        });

        btnSoundDetect.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                isSoundDetectMode = !isSoundDetectMode; // 자이로 모드 ON/OFF 전환
                if (isSoundDetectMode) {
                    currentMode = "SOUND DETECT";
                    rcStatus = "k";
                    Toast.makeText(getApplicationContext(), "Sound detect mode activated.", Toast.LENGTH_SHORT).show();
                } else {
                    currentMode = "Manual";
                    rcStatus = "m";
                    Toast.makeText(getApplicationContext(), "Sound detect mode deactivated.", Toast.LENGTH_SHORT).show();
                }
                tvMode.setText(currentMode);
            }
        });

        /*
        btnMusic.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                isMusicOn = !isMusicOn;
                if (isMusicOn) {
                    rcStatus = "h";
                    Toast.makeText(getApplicationContext(), "Music on.", Toast.LENGTH_SHORT).show();
                } else if (!isMusicOn){
                    rcStatus = "j";
                    Toast.makeText(getApplicationContext(), "Music off.", Toast.LENGTH_SHORT).show();
                }
            }
        });*/
        btnMusic.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // 노래 목록 정의
                final String[] songList = {"Sweet child o' mine", "Pirates of the Caribbean", "Mario Bros", "Stop"};
                final String[] songCodes = {"1", "2", "3", "4"}; // 각각의 노래에 대응하는 코드

                // 노래 선택 다이얼로그 생성
                AlertDialog.Builder builder = new AlertDialog.Builder(MainActivity.this);
                builder.setTitle("Select a Song");
                builder.setItems(songList, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        // 선택한 노래에 해당하는 코드 설정
                        String selectedCode = songCodes[which];
                        rcStatus = selectedCode;

                        // Bluetooth로 선택한 코드 전송
                        if (socket != null && socket.isConnected()) {
                            connectedThread.write(rcStatus);
                            if (!selectedCode.equals("4")) {
                                Toast.makeText(getApplicationContext(),
                                        "Playing: " + songList[which], Toast.LENGTH_SHORT).show();
                            } else {
                                Toast.makeText(getApplicationContext(),
                                        "Music stopped.", Toast.LENGTH_SHORT).show();
                            }
                        } else {
                            Toast.makeText(getApplicationContext(),
                                    "Bluetooth not connected. Please connect first.", Toast.LENGTH_SHORT).show();
                        }
                    }
                });

                // 다이얼로그 표시
                builder.create().show();
            }
        });



        /*btnManual.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                switch (event.getAction()){
                    case MotionEvent.ACTION_DOWN:
                        rcStatus = "m";
                        return  true;
                    case MotionEvent.ACTION_UP:
                        rcStatus = "n";
                        return  true;
                }
                return false;
            }
        });*/

        btnRight.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                switch (event.getAction()){
                    case MotionEvent.ACTION_DOWN:
                        rcStatus = "r";
                        return  true;
                    case MotionEvent.ACTION_UP:
                        rcStatus = "n";
                        return  true;
                }
                return false;
            }
        });

        btnLeft.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                switch (event.getAction()){
                    case MotionEvent.ACTION_DOWN:
                        rcStatus = "l";
                        return  true;
                    case MotionEvent.ACTION_UP:
                        rcStatus = "n";
                        return  true;
                }
                return false;
            }
        });

        btnUp.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                switch (event.getAction()){
                    case MotionEvent.ACTION_DOWN:
                        rcStatus = "u";
                        return  true;
                    case MotionEvent.ACTION_UP:
                        rcStatus = "n";
                        return  true;
                }
                return false;
            }
        });

        btnStop.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                switch (event.getAction()){
                    case MotionEvent.ACTION_DOWN:
                        rcStatus = "s";
                        return  true;
                    case MotionEvent.ACTION_UP:
                        rcStatus = "n";
                        return  true;
                }
                return false;
            }
        });

        btnDown.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                switch (event.getAction()){
                    case MotionEvent.ACTION_DOWN:
                        rcStatus = "d";
                        return  true;
                    case MotionEvent.ACTION_UP:
                        rcStatus = "n";
                        return  true;
                }
                return false;
            }
        });

        bluetoothHandler = new Handler(){
            @Override
            public void handleMessage(Message msg) {
                if(msg.what == BLUETOOTH_MSG_STATE){
                    String message = (String) msg.obj;

                    //Handle message
                }
            }
        };



        Thread sendData = new Thread(new Runnable() {
            @Override
            public void run() {
                while (true) {
                    try {
                        if (socket != null && socket.isConnected()) {
                            connectedThread.write(rcStatus);
                            Log.d("SendData Thread", "Sending: " + rcStatus);  // 주기적 전송 확인 로그
                            Thread.sleep(10); // 간격을 100ms로 조정하여 전송 속도를 줄임
                        }
                    } catch (InterruptedException e) {
                        Log.e("SendData Error", "InterruptedException occurred", e);
                    } catch (NullPointerException e) {
                        Log.e("SendData Error", "Socket not connected", e);
                    }
                }
            }
        });

        sendData.start();

        bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();

        btnBluetoothEnable.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(!bluetoothAdapter.isEnabled()){
                    Intent enable = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
                    startActivityForResult(enable, 0);
                }else{
                    Toast.makeText(getApplicationContext(), "Already enabled or not connected.", Toast.LENGTH_SHORT).show();
                }
            }
        });

        btnBluetoothDisconnect.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                try{
                    if(socket.isConnected()) {
                        socket.close();
                        Toast.makeText(getApplicationContext(), "Disconnected.", Toast.LENGTH_SHORT).show();
                    }
                }catch (IOException e){
                    Log.wtf("IO E", "Disconnect");
                }catch (NullPointerException e){
                    Log.wtf("Null E", "Disconnect");
                }
            }
        });

        btnBluetoothConnect.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                try{
                    if(socket.isConnected()) {
                        Toast.makeText(getApplicationContext(), "Already Connected. Disconnect before reconnect.", Toast.LENGTH_SHORT).show();
                        return;
                    }
                }catch (NullPointerException e){
                    Log.wtf("Null", "Connect");
                }

                pairedDevices = bluetoothAdapter.getBondedDevices();

                AlertDialog.Builder dialogBuilder = new AlertDialog.Builder(MainActivity.this);
                dialogBuilder.setIcon(R.mipmap.bluetooth_connect);
                dialogBuilder.setTitle("Select RC Car");

                final ArrayList<String> deviceMACs = new ArrayList<>();

                ArrayAdapter<String> deviceDetails = new ArrayAdapter<>(MainActivity.this, android.R.layout.select_dialog_singlechoice);

                for(BluetoothDevice device : pairedDevices){
                    deviceDetails.add(device.getName() + " " + device.getAddress());
                    deviceMACs.add(device.getAddress());
                }

                dialogBuilder.setAdapter(deviceDetails, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        BluetoothDevice device = bluetoothAdapter.getRemoteDevice(deviceMACs.get(which));

                        try {
                            socket = createBluetoothSocket(device);
                        }catch (IOException e){
                            Log.wtf("IO E", "create socket");
                        }

                        try {
                            socket.connect();
                            Toast.makeText(getApplicationContext(), "Connected.", Toast.LENGTH_SHORT).show();
                        }catch (IOException e){
                            Log.wtf("IO E", "Connect");

                            Toast.makeText(getApplicationContext(), "Connection Error.", Toast.LENGTH_SHORT).show();
                            try {
                                socket.close();
                            } catch (IOException er) {
                                Log.wtf("IO E", "Close");
                            }
                        }

                        connectedThread = new ConnectedThread(socket);
                        connectedThread.start();
                    }
                });

                dialogBuilder.show();
            }
        });
    }

    private BluetoothSocket createBluetoothSocket(BluetoothDevice device) throws IOException {

        return  device.createRfcommSocketToServiceRecord(BTMODULEUUID);
        //creates secure outgoing connecetion with BT device using UUID
    }

    @Override
    public void onSensorChanged(SensorEvent event) {
        if (!isGyroMode) return;
        if (event.sensor.getType() == Sensor.TYPE_GYROSCOPE) {
            // 자이로 데이터 업데이트
            gyroValues[0] = event.values[0]; // X축
            gyroValues[1] = event.values[1]; // Y축
            gyroValues[2] = event.values[2]; // Z축

            controlRC(gyroValues); // 자이로 값에 따라 RC카 제어
        }
    }

    private void controlRC(float[] gyroValues) {
        if (!isGyroMode) return;
        float threshold = 2.0f; // 자이로 값 임계값 (필요에 따라 조정)

        if (gyroValues[1] > threshold) {
            rcStatus = "u"; // 전진
        } else if (gyroValues[1] < -threshold) {
            rcStatus = "d"; // 후진
        } else if (gyroValues[0] > threshold) {
            rcStatus = "r"; // 우회전
        } else if (gyroValues[0] < -threshold) {
            rcStatus = "l"; // 좌회전
        } /*else {
            rcStatus = "s"; // 정지
        } */

        // Bluetooth로 데이터 전송
        /*
        if (socket != null && socket.isConnected()) {
            connectedThread.write(rcStatus);
        }*/
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int i) {

    }

    private class ConnectedThread extends Thread{
        private final InputStream inputStream;
        private final OutputStream outputStream;

        public ConnectedThread(BluetoothSocket socket){
            InputStream inputStream = null;
            OutputStream outputStream = null;
            try {
                inputStream = socket.getInputStream();
                outputStream = socket.getOutputStream();
            }catch (IOException e){
                Log.wtf("IO E", "Construct");
            }

            this.inputStream = inputStream;
            this.outputStream = outputStream;
        }

        @Override
        public void run() {
            byte[] buffer = new byte[256];
            int bytes;

            while(true){
                try {
                    bytes = inputStream.read(buffer);
                    String message = new String(buffer, 0, bytes);
                    bluetoothHandler.obtainMessage(BLUETOOTH_MSG_STATE, bytes, -1, message).sendToTarget();
                }catch (IOException e){
                    Log.wtf("IO E", "run");
                    break;
                }
            }
        }

        public void write(String input){
            byte[] buffer = input.getBytes();
            try{
                outputStream.write(buffer);
            }catch (IOException e){
                Log.wtf("IO E", "write");
            }
        }
    }
}
