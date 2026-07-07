class LoanDetailsResponseEntity {
    final bool success;
    final LoanDetailsDataEntity data;

    LoanDetailsResponseEntity({
        required this.success,
        required this.data,
    });
}

class LoanDetailsDataEntity {
    final CabeceraEntity cabecera;
    final List<LoanDetailCronogramaEntity> cronograma;

    LoanDetailsDataEntity({
        required this.cabecera,
        required this.cronograma,
    });
}

class CabeceraEntity {
    final String loanCode;
    final String estadoEtiqueta;
    final double montoPrincipal;
    final String moneda;
    final double interesTotal;
    final double totalAPagar;
    final double saldoPendiente;
    final double progresoPagoPct;

    CabeceraEntity({
        required this.loanCode,
        required this.estadoEtiqueta,
        required this.montoPrincipal,
        required this.moneda,
        required this.interesTotal,
        required this.totalAPagar,
        required this.saldoPendiente,
        required this.progresoPagoPct,
    });
}

class LoanDetailCronogramaEntity {
    final String quotaId;
    final String mesEtiqueta;
    final String diaEtiqueta;
    final String textoCuota;
    final String estadoCuota;
    final int montoTotalCuota;
    final bool permitePago;

    LoanDetailCronogramaEntity({
        required this.quotaId,
        required this.mesEtiqueta,
        required this.diaEtiqueta,
        required this.textoCuota,
        required this.estadoCuota,
        required this.montoTotalCuota,
        required this.permitePago,
    });
}
