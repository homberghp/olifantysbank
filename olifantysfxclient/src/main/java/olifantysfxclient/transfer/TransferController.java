package olifantysfxclient.transfer;

import javafx.application.Platform;
import javafx.fxml.FXML;

/**
 *
 * @author Pieter van den Hombergh {@code <p.vandenhombergh@fontys.nl>}
 */
public class TransferController {

    @FXML
    void close(){
        Platform.exit();
        System.exit(0);
    }
    @FXML
    void transfer(){
    }
    @FXML
    void cancel(){
    
    }
}
