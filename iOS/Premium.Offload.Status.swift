extension Premium.Offload {
    enum Status {
        case
        loading,
        notfound,
        uploaded,
        error(Error)
    }
}
