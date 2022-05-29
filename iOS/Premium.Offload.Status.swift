extension Premium.Offload {
    enum Status {
        case
        loading,
        notfound,
        cleaning,
        finished,
        error(Error)
    }
}
