extension Store {
    enum Status: Equatable {
        case
        loading,
        ready,
        error(String)
    }
}
