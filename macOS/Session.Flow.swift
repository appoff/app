import Offline

extension Session {
    enum Flow {
        case
        main,
        create,
        scan,
        loading(Factory),
        unzip(Project),
        offload(Header),
        download(Header),
        share(Header),
        navigate(Schema, Bufferer)
    }
}
