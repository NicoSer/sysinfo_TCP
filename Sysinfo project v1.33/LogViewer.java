/*
 * LogViewer - TCP Log Receiver
 *
 * Copyright (c) 2025 NicoSer
 *
 * Licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
 * You may use and share this program for personal, educational, or organizational purposes,
 * but you may not modify it or use it commercially.
 *
 * Full license: https://creativecommons.org/licenses/by-nc-nd/4.0/
 */
import javax.swing.*;
import java.awt.*;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.InetAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.concurrent.*;
import java.io.File;
import java.io.PrintWriter;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

public class LogViewer extends JFrame {
    private static final String APP_VERSION = "1.33";
    private JTextArea logArea;
    private JTextArea statusArea;
    private JLabel countdownLabel;
    private JLabel listenerInfoLabel;

    private ServerSocket serverSocket;
    private ExecutorService executor;
    private ScheduledExecutorService clearScheduler;

    private ScheduledFuture<?> countdownFuture;

    private volatile boolean running = true;

    private boolean autoClearEnabled = true;
    private int autoClearSeconds = 10;
    private int listenPort = 2222;


   private void loadConfig() {
    File configFile = new File("logviewer.conf");

    if (!configFile.exists()) {
        try (PrintWriter writer = new PrintWriter(configFile)) {
            writer.println("# LogViewer Configuration");
            writer.println("listen_port=" + listenPort);
            writer.println("auto_clear_enabled=" + autoClearEnabled);
            writer.println("auto_clear_seconds=" + autoClearSeconds);
            // Remove or comment out appendStatus here
            // appendStatus("Config file not found. Created default config file.");
        } catch (IOException e) {
            // You can print to console instead of appendStatus
            System.err.println("Failed to create default config file: " + e.getMessage());
        }
        return;
    }

    try (BufferedReader reader = new BufferedReader(new FileReader(configFile))) {
        String line;
        while ((line = reader.readLine()) != null) {
            if (line.trim().isEmpty() || line.startsWith("#")) continue;

            String[] parts = line.split("=", 2);
            if (parts.length != 2) continue;

            String key = parts[0].trim();
            String value = parts[1].trim();

            switch (key) {
                case "listen_port":
                    listenPort = Integer.parseInt(value);
                    break;
                case "auto_clear_enabled":
                    autoClearEnabled = Boolean.parseBoolean(value);
                    break;
                case "auto_clear_seconds":
                    autoClearSeconds = Integer.parseInt(value);
                    break;
            }
        }
        // appendStatus("Loaded settings from config file."); // comment out here too
    } catch (Exception e) {
        System.err.println("Failed to read config file: " + e.getMessage());
    }
}

private void saveConfig() {
    File configFile = new File("logviewer.conf");
    try (PrintWriter writer = new PrintWriter(configFile)) {
        writer.println("# LogViewer Configuration");
        writer.println("listen_port=" + listenPort);
        writer.println("auto_clear_enabled=" + autoClearEnabled);
        writer.println("auto_clear_seconds=" + autoClearSeconds);
        appendStatus("Settings saved to config file.");
    } catch (IOException e) {
        appendStatus("Failed to save config: " + e.getMessage());
    }
}

private void restartAppWithCountdown(int seconds) {
    new Thread(() -> {
        try {
            for (int i = seconds; i > 0; i--) {
                final int count = i;
                SwingUtilities.invokeLater(() -> appendStatus("Restarting in " + count + "..."));
                Thread.sleep(1000);
            }

            // Get path to java binary
            String javaBin = System.getProperty("java.home") + File.separator + "bin" + File.separator + "java";

            // Get path to current JAR file
            File jarFile = new File(LogViewer.class.getProtectionDomain().getCodeSource().getLocation().toURI());

            if (!jarFile.getName().endsWith(".jar")) {
                appendStatus("Not running from a JAR, auto-restart skipped.");
                return;
            }

            // Build process command
            ProcessBuilder builder = new ProcessBuilder(javaBin, "-jar", jarFile.getPath());
            builder.start();

            // Exit current app
            System.exit(0);

        } catch (Exception e) {
            e.printStackTrace();
            SwingUtilities.invokeLater(() ->
                appendStatus("Restart failed: " + e.getMessage())
            );
        }
    }).start();
}



    public LogViewer() {
        super("Log Viewer v" + APP_VERSION);
        loadConfig();
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setSize(800, 700);
        setLocationRelativeTo(null);

        logArea = new JTextArea();
        logArea.setFont(new Font("Terminal", Font.PLAIN, 12));
        logArea.setEditable(false);
        JScrollPane logScroll = new JScrollPane(logArea);

        statusArea = new JTextArea();
        statusArea.setFont(new Font("Terminal", Font.PLAIN, 11));
        statusArea.setEditable(false);
        statusArea.setBackground(Color.BLACK);
        statusArea.setForeground(Color.WHITE);
        statusArea.setRows(4);
        JScrollPane statusScroll = new JScrollPane(statusArea);

        countdownLabel = new JLabel("Clearing logs in: -- seconds");
        countdownLabel.setFont(new Font("Segoe UI", Font.PLAIN, 11));
        countdownLabel.setOpaque(true);
        countdownLabel.setBackground(null);
        countdownLabel.setBorder(BorderFactory.createEmptyBorder(5, 5, 5, 5));

        JButton exitButton = new JButton("Exit");
        exitButton.setPreferredSize(new Dimension(100, 30));
        exitButton.addActionListener(e -> {
            stopServer();
            System.exit(0);
        });

        listenerInfoLabel = new JLabel(getListenerInfoText());
        listenerInfoLabel.setFont(new Font("Segoe UI", Font.PLAIN, 12));
        listenerInfoLabel.setBorder(BorderFactory.createEmptyBorder(0, 16, 0, 10));

        // Settings Tab
        JPanel settingsPanel = new JPanel();
        settingsPanel.setLayout(new BoxLayout(settingsPanel, BoxLayout.Y_AXIS));
        settingsPanel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

        JCheckBox autoClearCheckBox = new JCheckBox("Enable Auto Clear", autoClearEnabled);
        autoClearCheckBox.setFont(new Font("Segoe UI", Font.PLAIN, 12));
        autoClearCheckBox.addActionListener(e -> {
            autoClearEnabled = autoClearCheckBox.isSelected();
            if (!autoClearEnabled) {
                cancelCountdown();
                countdownLabel.setText("Auto Clear Disabled");
                countdownLabel.setBackground(null);
            } else {
                countdownLabel.setText("Clearing logs in: -- seconds");
                countdownLabel.setBackground(null);
            }
        });

        JSlider autoClearSlider = new JSlider(7, 120, autoClearSeconds);
        autoClearSlider.setMajorTickSpacing(5);
        autoClearSlider.setMinorTickSpacing(1);
        autoClearSlider.setPaintTicks(true);
        autoClearSlider.setPaintLabels(true);
        autoClearSlider.setFont(new Font("Segoe UI", Font.PLAIN, 10));

        JLabel sliderValueLabel = new JLabel("Selected time: " + autoClearSeconds + " seconds");
        sliderValueLabel.setFont(new Font("Segoe UI", Font.PLAIN, 11));

        autoClearSlider.addChangeListener(e -> {
            int val = autoClearSlider.getValue();
            autoClearSeconds = val;
            sliderValueLabel.setText("Selected time: " + val + " seconds");
            if (autoClearEnabled && countdownFuture != null && !countdownFuture.isDone()) {
                resetCountdown();
            }
        });

        // Port control
        JPanel portPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
        portPanel.add(new JLabel("Listener Port: "));
        JSpinner portSpinner = new JSpinner(new SpinnerNumberModel(listenPort, 1024, 65535, 1));
        portSpinner.setFont(new Font("Segoe UI", Font.PLAIN, 12));
        portSpinner.setPreferredSize(new Dimension(80, 25));

        JButton applyPortButton = new JButton("Apply Settings");
        applyPortButton.setFont(new Font("Segoe UI", Font.PLAIN, 11));
        applyPortButton.setPreferredSize(new Dimension(120, 25));

applyPortButton.addActionListener(e -> {
    int newPort = (Integer) portSpinner.getValue();
    boolean newAutoClearEnabled = autoClearCheckBox.isSelected();
    int newAutoClearSeconds = autoClearSlider.getValue();

    boolean restartServer = false;

    // Check if port changed
    if (newPort != listenPort) {
        appendStatus("Changing port from " + listenPort + " to " + newPort + "...");
       stopServer();
       listenPort = newPort;
       restartServer = false;
       appendStatus("Port " + listenPort + " has been applied to the config. Restarting app in 3...");
       restartAppWithCountdown(3);
    }

    // Update auto clear settings
    autoClearEnabled = newAutoClearEnabled;
    autoClearSeconds = newAutoClearSeconds;

    if (restartServer) {
        listenerInfoLabel.setText(getListenerInfoText());
        startServer();
        appendStatus("New port set to " + listenPort + ".");
    }

    appendStatus("Settings applied.");
    saveConfig();

    // Update countdown/reset UI if needed
    if (autoClearEnabled) {
        resetCountdown();
    } else {
        cancelCountdown();
        countdownLabel.setText("Auto Clear Disabled");
    }
});

        // About Tab
        JPanel aboutPanel = new JPanel();
        aboutPanel.setLayout(new BoxLayout(aboutPanel, BoxLayout.Y_AXIS));
        aboutPanel.setBorder(BorderFactory.createEmptyBorder(20, 20, 20, 20));
        
        JLabel aboutTitle = new JLabel("Log Viewer v" + APP_VERSION);
        aboutTitle.setFont(new Font("Segoe UI", Font.BOLD, 14));
        
        JLabel aboutAuthor = new JLabel("Made by Nicolas");
        aboutAuthor.setFont(new Font("Segoe UI", Font.PLAIN, 12));
        
        JLabel aboutLink = new JLabel("<html><a href='https://github.com/NicoSer'>github.com/NicoSer</a></html>");
        aboutLink.setFont(new Font("Segoe UI", Font.PLAIN, 12));
        aboutLink.setCursor(new Cursor(Cursor.HAND_CURSOR));
        aboutLink.addMouseListener(new java.awt.event.MouseAdapter() {
            @Override
            public void mouseClicked(java.awt.event.MouseEvent e) {
                try {
                    java.awt.Desktop.getDesktop().browse(new java.net.URI("https://github.com/NicoSer"));
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
        });
        
        aboutPanel.add(aboutTitle);
        aboutPanel.add(Box.createRigidArea(new Dimension(0, 10)));
        aboutPanel.add(aboutAuthor);
        aboutPanel.add(aboutLink);

        portPanel.add(portSpinner);
        portPanel.add(applyPortButton);

        settingsPanel.add(autoClearCheckBox);
        settingsPanel.add(Box.createRigidArea(new Dimension(0, 10)));
        settingsPanel.add(autoClearSlider);
        settingsPanel.add(sliderValueLabel);
        settingsPanel.add(Box.createRigidArea(new Dimension(0, 20)));
        settingsPanel.add(portPanel);

        // Tabs
        JTabbedPane tabbedPane = new JTabbedPane();
        tabbedPane.addTab("Logs", logScroll);
        tabbedPane.addTab("Settings", settingsPanel);
        tabbedPane.addTab("About", aboutPanel);

        // Bottom panel
        JPanel bottomPanel = new JPanel(new BorderLayout());
        bottomPanel.add(countdownLabel, BorderLayout.WEST);

        JPanel rightBottomPanel = new JPanel(new FlowLayout(FlowLayout.RIGHT, 5, 0));
        rightBottomPanel.add(listenerInfoLabel);
        rightBottomPanel.add(exitButton);
        bottomPanel.add(rightBottomPanel, BorderLayout.EAST);

        // Layout setup
        JPanel centerPanel = new JPanel(new BorderLayout());
        centerPanel.add(tabbedPane, BorderLayout.CENTER);
        centerPanel.add(statusScroll, BorderLayout.SOUTH);

        getContentPane().setLayout(new BorderLayout());
        getContentPane().add(centerPanel, BorderLayout.CENTER);
        getContentPane().add(bottomPanel, BorderLayout.SOUTH);

        setVisible(true);

        startServer();
    }

    private String getListenerInfoText() {
        try {
            String ip = InetAddress.getLocalHost().getHostAddress();
            return ip + ", Listening to: Port " + listenPort;
        } catch (Exception e) {
            return "Unknown IP, Listening to: Port " + listenPort;
        }
    }

private void startServer() {
    try {
        serverSocket = new ServerSocket(listenPort);
        executor = Executors.newSingleThreadExecutor();

        // Ensure a fresh scheduler, even if the previous one was shut down
        if (clearScheduler == null || clearScheduler.isShutdown() || clearScheduler.isTerminated()) {
            clearScheduler = Executors.newSingleThreadScheduledExecutor();
        }

        executor.submit(() -> {
            while (running) {
                try {
                    Socket client = serverSocket.accept();
                    BufferedReader reader = new BufferedReader(new InputStreamReader(client.getInputStream()));
                    StringBuilder buffer = new StringBuilder();
                    String line;
                    while ((line = reader.readLine()) != null) {
                        buffer.append(line).append("\n");
                    }
                    reader.close();
                    client.close();

                    String logs = buffer.toString().trim();

                    if (!logs.isEmpty()) {
                        String timestamp = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());
                        SwingUtilities.invokeLater(() -> {
                        logArea.setText(logs);
                        appendStatus("Live update received at " + timestamp);
                        if (autoClearEnabled) {
                            resetCountdown();
                            }
                        });
                    }

                } catch (IOException e) {
                    if (running) {
                        SwingUtilities.invokeLater(() -> appendStatus("Error: " + e.getMessage()));
                    }
                }
            }
        });
    } catch (IOException e) {
        appendStatus("Server failed to start: " + e.getMessage());
    }
}

    private void appendStatus(String message) {
        statusArea.append(message + "\n");
        statusArea.setCaretPosition(statusArea.getDocument().getLength());
    }

private void resetCountdown() {
    // Recreate scheduler if it's shut down
    if (clearScheduler == null || clearScheduler.isShutdown() || clearScheduler.isTerminated()) {
        clearScheduler = Executors.newSingleThreadScheduledExecutor();
    }

    cancelCountdown();

    countdownLabel.setBackground(new Color(255, 204, 204));
    final int[] countdownValue = {autoClearSeconds};

    countdownLabel.setText("Clearing logs in: " + countdownValue[0] + " seconds");

    countdownFuture = clearScheduler.scheduleAtFixedRate(() -> {
        countdownValue[0]--;
        SwingUtilities.invokeLater(() ->
            countdownLabel.setText("Clearing logs in: " + countdownValue[0] + " seconds")
        );

        if (countdownValue[0] <= 0) {
            SwingUtilities.invokeLater(() -> {
                logArea.setText("");
                String time = new SimpleDateFormat("HH:mm:ss").format(new Date());
                appendStatus("Logs auto-cleared at " + time);
                countdownLabel.setText("Clearing logs in: -- seconds");
                countdownLabel.setBackground(null);
            });
            cancelCountdown();
        }
    }, 1, 1, TimeUnit.SECONDS);
}

    private void cancelCountdown() {
        if (countdownFuture != null && !countdownFuture.isDone()) {
            countdownFuture.cancel(true);
            countdownLabel.setText("Clearing logs in: -- seconds");
            countdownLabel.setBackground(null);
        }
    }

    private void stopServer() {
        running = false;
        try {
            if (serverSocket != null && !serverSocket.isClosed()) {
                serverSocket.close();
            }
        } catch (IOException ignored) {}

        if (executor != null && !executor.isShutdown()) {
            executor.shutdownNow();
        }

        if (clearScheduler != null && !clearScheduler.isShutdown()) {
            clearScheduler.shutdownNow();
        }
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(LogViewer::new);
    }
}

/**
*   _   _ _               _           
*  | \ | (_) ___ ___   __| | _____  __
*  |  \| | |/ __/ _ \ / _` |/ _ \ \/ /
*  | |\  | | (_| (_) | (_| |  __/>  < 
*  |_| \_|_|\___\___/ \__,_|\___/_/\_\
*                                     
*/