package olifantysfxclient.bankstatement;

import javafx.application.Platform;
import javafx.fxml.FXML;

/**
 *
 * @author Pieter van den Hombergh {@code <p.vandenhombergh@fontys.nl>}
 */
public class BankStatementController {
    @FXML
    void close(){
        Platform.exit();
        System.exit(0);
    }

}
